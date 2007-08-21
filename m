From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
	support in IPoIB
Date: Tue, 21 Aug 2007 17:09:12 -0400
Message-ID: <1187730552.5324.76.camel@localhost>
References: <OFFFECFAD7.CF3FF115-ON6525733A.0020AE37-6525733A.00218365@in.ibm.com>
	<20070821.001824.105429474.davem@davemloft.net>
	<1187699422.5324.41.camel@localhost>
	<20070821.115143.23013721.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jagana@us.ibm.com, gaagaan@gmail.com, jeff@garzik.org,
	Robert.Olsson@data.slu.se, kumarkr@linux.ibm.com,
	rdreier@cisco.com, peter.p.waskiewicz.jr@intel.com,
	mcarlson@broadcom.com, netdev@vger.kernel.org, sri@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	johnpol@2ka.mipt.ru, shemminger@linux-foundation.org,
	kaber@trash.net, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070821.115143.23013721.davem@davemloft.net>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-21-08 at 11:51 -0700, David Miller wrote:

> Because TSO does batching already, so it's a very good
> "tit for tat" comparison of the new batching scheme
> vs. an existing one.

Fair enough - I may have read too much into your email then;->

For bulk type of apps (where TSO will make a difference) this a fair
test. Hence i agree the 16KB buffer size is not sensible if the goal is
to simulate such an app. 
However (and this is where i read too much into what you were saying)
that the test by itself is insufficient comparison. You gotta look at
the other side of the coin i.e. at apps where TSO wont buy much.
Examples, a busy ssh or irc server and you could go as far as looking at
the most pre-dominant app on the wild west, http (average page size from
a few years back was in the range of 10-20K and can be simulated with
good ole netperf/iperf). 

cheers,
jamal
