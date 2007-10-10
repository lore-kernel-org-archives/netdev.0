From: jamal <hadi@cyberus.ca>
Subject: Re: [ofa-general] Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Wed, 10 Oct 2007 09:08:48 -0400
Message-ID: <1192021728.4853.17.camel@localhost>
References: <20071010091644.GA9807@one.firstfloor.org>
	<20071010.022550.21928751.davem@davemloft.net>
	<20071010102331.GA10496@one.firstfloor.org>
	<20071010.034446.85819294.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, jeff@garzik.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	andi@firstfloor.org, general@lists.openfabrics.org,
	netdev@vger.kernel.org, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com, shemminger@linux-foundation.org, kaber@trash.net,
	mchan@broadcom.com, jagana@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20071010.034446.85819294.davem@davemloft.net>
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

On Wed, 2007-10-10 at 03:44 -0700, David Miller wrote:

> I've always gotten very poor results when increasing the TX queue a
> lot, for example with NIU the point of diminishing returns seems to
> be in the range of 256-512 TX descriptor entries and this was with
> 1.6Ghz cpus.

Is it interupt per packet? From my experience, you may find interesting
results varying tx interupt mitigation parameters in addition to the
ring parameters.
Unfortunately when you do that, optimal parameters also depends on
packet size. so what may work for 64B, wont work well for 1400B.

cheers,
jamal
