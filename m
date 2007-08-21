From: jamal <hadi@cyberus.ca>
Subject: [ofa-general] Re: [PATCH 0/9 Rev3] Implement batching skb API and
	support in IPoIB
Date: Tue, 21 Aug 2007 08:30:22 -0400
Message-ID: <1187699422.5324.41.camel@localhost>
References: <OFFFECFAD7.CF3FF115-ON6525733A.0020AE37-6525733A.00218365@in.ibm.com>
	<20070821.001824.105429474.davem@davemloft.net>
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
In-Reply-To: <20070821.001824.105429474.davem@davemloft.net>
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

On Tue, 2007-21-08 at 00:18 -0700, David Miller wrote:

> Using 16K buffer size really isn't going to keep the pipe full enough
> for TSO. 

Why the comparison with TSO (or GSO for that matter)?
Seems to me that is only valid/fair if you have a single flow. 
Batching is multi-flow focused (or i should say flow-unaware).

cheers,
jamal
