From: "Neel Patel (neepatel)" <neepatel@cisco.com>
Subject: RE: [PATCH 02/11] enic: remove unnecessary setting of skb->dev
Date: Fri, 13 Jul 2012 04:56:42 +0000
Message-ID: <644DFB2E795E0348A1614A34EE0D3571014182@xmb-rcd-x05.cisco.com>
References: <1341878975-10577-1-git-send-email-jdmason@kudzu.us>
	<1341878975-10577-2-git-send-email-jdmason@kudzu.us>
 <CAPoiz9y2D15o4ueTCWPQHiNHexBVXSABO_1ghpKtYCruSDV-Ew@mail.gmail.com>
 <6CE81A2095B0024BBC77007BD04E5538053EA0@xmb-aln-x02.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Nishank Trivedi (nistrive)" <nistrive@cisco.com>
To: "Christian Benvenuti (benve)" <benve@cisco.com>,
	Jon Mason <jdmason@kudzu.us>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-1.cisco.com ([173.37.86.72]:33065 "EHLO
	rcdn-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100Ab2GMFGH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 01:06:07 -0400
In-Reply-To: <6CE81A2095B0024BBC77007BD04E5538053EA0@xmb-aln-x02.cisco.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jon,
The change in enic_main.c looks good.
_ Neel

-----Original Message-----
From: Christian Benvenuti (benve) 
Sent: Thursday, July 12, 2012 2:23 PM
To: Jon Mason; David S. Miller
Cc: netdev@vger.kernel.org; Neel Patel (neepatel); Nishank Trivedi (nistrive)
Subject: RE: [PATCH 02/11] enic: remove unnecessary setting of skb->dev

Jon,
  Roopa is not in the maintainer list anymore.
Sorry about that.
We will update MAINTAINERS. 

BTW, the change in enic_main.c looks good.

/Chris

> -----Original Message-----
> From: Jon Mason [mailto:jdmason@kudzu.us]
> Sent: Thursday, July 12, 2012 2:19 PM
> To: David S. Miller
> Cc: netdev@vger.kernel.org; Christian Benvenuti (benve); Neel Patel 
> (neepatel); Nishank Trivedi
> (nistrive)
> Subject: Re: [PATCH 02/11] enic: remove unnecessary setting of 
> skb->dev
> 
> On Mon, Jul 9, 2012 at 5:09 PM, Jon Mason <jdmason@kudzu.us> wrote:
> > skb->dev is being unnecessarily set after calling eth_type_trans.
> > eth_type_trans already sets skb->dev to the proper value, thus 
> > making this unnecessary.
> >
> > Signed-off-by: Jon Mason <jdmason@kudzu.us>
> > Cc: Christian Benvenuti <benve@cisco.com>
> > Cc: Roopa Prabhu <roprabhu@cisco.com>
> 
> This address bounced.  Anyone know of an updated address for Roopa or 
> should they be removed from the MAINTAINERS list?
> 
> > Cc: Neel Patel <neepatel@cisco.com>
> > Cc: Nishank Trivedi <nistrive@cisco.com>
> > ---
> >  drivers/net/ethernet/cisco/enic/enic_main.c |    2 --
> >  1 file changed, 2 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c
> b/drivers/net/ethernet/cisco/enic/enic_main.c
> > index 8132c78..ad1468b 100644
> > --- a/drivers/net/ethernet/cisco/enic/enic_main.c
> > +++ b/drivers/net/ethernet/cisco/enic/enic_main.c
> > @@ -1300,8 +1300,6 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
> >                         skb->ip_summed = CHECKSUM_COMPLETE;
> >                 }
> >
> > -               skb->dev = netdev;
> > -
> >                 if (vlan_stripped)
> >                         __vlan_hwaccel_put_tag(skb, vlan_tci);
> >
> > --
> > 1.7.9.5
> >
