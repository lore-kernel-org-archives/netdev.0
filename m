From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 1/1] xen/netback: correctly calculate required slots of
 skb.
Date: Wed, 10 Jul 2013 08:48:51 +0100
Message-ID: <20130710074851.GH19798@zion.uk.xensource.com>
References: <1373350520-19985-1-git-send-email-annie.li@oracle.com>
 <20130709161612.GF19798@zion.uk.xensource.com>
 <51DCC795.2070806@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xensource.com>,
	<netdev@vger.kernel.org>, <Ian.Campbell@citrix.com>,
	<konrad.wilk@oracle.com>
To: annie li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:55148 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751575Ab3GJHsw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jul 2013 03:48:52 -0400
Content-Disposition: inline
In-Reply-To: <51DCC795.2070806@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 10, 2013 at 10:31:49AM +0800, annie li wrote:
[...]
> >This seems to differ from netbk_gop_frag_copy. In that function it's
> >like
> >
> >     if (*head && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
> 
> I mixed netbk_gop_frag_copy and xen_netbk_count_skb_slots just now,
> so please ignore the comments here in my last email.
> In xen_netbk_count_skb_slots, we have following code already, so it
> is not necessary to add gso condition here.
> 
>         if (skb_shinfo(skb)->gso_size)
>                 count++;
> 

Oh I see. But the condition still seems to be different from the
original one -- you missed !vif->gso_prefix.


Wei.
