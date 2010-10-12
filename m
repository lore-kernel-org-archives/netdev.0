From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [PATCH net-next] bnx2x: Fixing a typo: added a missing RSS
 enablement
Date: Tue, 12 Oct 2010 13:08:02 -0700
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE4283D5@SJEXCHCCR02.corp.ad.broadcom.com>
References: <1286910141.16797.23.camel@lb-tlvb-dmitry>
 <1286911579.1117.76.camel@Joe-Laptop>
 <20101012.123142.59664847.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	"joe@perches.com" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3510 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754278Ab0JLUIT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 16:08:19 -0400
In-Reply-To: <20101012.123142.59664847.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, October 12, 2010 9:32 PM
> To: joe@perches.com
> Cc: Dmitry Kravkov; netdev@vger.kernel.org; eric.dumazet@gmail.com;
> Vladislav Zolotarov; Eilon Greenstein
> Subject: Re: [PATCH net-next] bnx2x: Fixing a typo: added a missing RSS
> enablement
> 
> From: Joe Perches <joe@perches.com>
> Date: Tue, 12 Oct 2010 12:26:19 -0700
> 
> > On Tue, 2010-10-12 at 21:02 +0200, Dmitry Kravkov wrote:
> >> @@ -2486,6 +2486,7 @@ void bnx2x_pf_init(struct bnx2x *bp)
> >>  	 * if (is_eth_multi(bp))
> >>  	 *	flags |= FUNC_FLG_RSS;
> >>  	 */
> >> +	flags |= FUNC_FLG_RSS;
> >>
> >>  	/* function setup */
> >>  	if (flags & FUNC_FLG_RSS) {
> >
> > Then the "if (flags & FUNC_FLG_RSS)" test should be removed.
> 
> Yeah it probably should.  If necessary it could be added back
> later.

Thanks, Joe. We will consider removing this "if" and will post
an appropriate patch. Most likely in the close patch series we
have promised to respin... ;)

Thanks to all, guys.
vlad



