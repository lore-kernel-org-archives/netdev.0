From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] sh_eth: r8a7790: Handle the RFE (Receive FIFO overflow
 Error) interrupt
Date: Wed, 31 Jul 2013 09:32:15 +0900
Message-ID: <20130731003215.GF17209@verge.net.au>
References: <1375142928-17769-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
 <51F7CADE.5070801@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51F7CADE.5070801@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 30, 2013 at 06:17:02PM +0400, Sergei Shtylyov wrote:
> Hello.
> 
> On 30-07-2013 4:08, Laurent Pinchart wrote:
> 
> >The RFE interrupt is enabled for the r8a7790 but isn't handled,
> >resulting in the interrupts core noticing unhandled interrupts, and
> >eventually disabling the ethernet IRQ.
> 
> >Fix it by adding RFE to the bitmask of error interrupts to be handled
> >for r8a7790.
> 
>    So, Simon hasn't synced his patch to my late bug fix in 3.10...

Sorry for missing that.

> Did this patch help you with your NFS boot issue, Laurent?
> 
> >Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
> 
> WBR, Sergei
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sh" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
