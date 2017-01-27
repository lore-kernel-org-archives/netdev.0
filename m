From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2 net-next 1/2] ravb: Add tx and rx clock internal
 delays mode of APSR
Date: Fri, 27 Jan 2017 20:40:33 +0100
Message-ID: <20170127194030.GA18706@verge.net.au>
References: <1485542120-10205-1-git-send-email-horms+renesas@verge.net.au>
 <1485542120-10205-2-git-send-email-horms+renesas@verge.net.au>
 <0570b250-83eb-fbac-de2a-0ea99a7250c2@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:38209 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbdA0TlW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 14:41:22 -0500
Content-Disposition: inline
In-Reply-To: <0570b250-83eb-fbac-de2a-0ea99a7250c2@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2017 at 10:05:58PM +0300, Sergei Shtylyov wrote:
> On 01/27/2017 09:35 PM, Simon Horman wrote:
> 
> >From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> >
> >This patch enables tx and rx clock internal delay modes (TDM and RDM).
> >
> >This is to address a failure in the case of 1Gbps communication using the
> >by salvator-x board with the KSZ9031RNX phy. This has been reported to
> >occur with both the r8a7795 (H3) and r8a7796 (M3-W) SoCs.
> >
> >With this change APSR internal delay modes are enabled for
> >"rgmii-id", "rgmii-rxid" and "rgmii-txid" phy modes as follows:
> >
> >phy mode   | ASPR delay mode
> >-----------+----------------
> >rgmii-id   | TDM and RDM
> >rgmii-rxid | RDM
> >rgmii-txid | TDM
> >
> >Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> >Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> 
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> >---
> >v2 [Simon Horman]
> >* As suggested by Sergei Shtylyov
> >  - Add a comment to indicate that APSR_DM appears to be undocumented.
> >  - Move chip_id check outside of ravb_set_delay_mode for consistency
> >  - Call ravb_modify() once in ravb_set_delay_mode()
> >* Enhance comment before calls to ravb_set_delay_mode()
> 
>    Well, I meant to say that the comment should precede the body of the
> function, not be repeated at every call...

I scratched my head trying to work out what you meant... and guessed wrong.

> >* Remove unnecessary break from end of switch statement.
> 
>   Come on, you did remove all the *switch*. :-)

Yes, after I wrote the comment above :)
