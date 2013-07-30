From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: r8a7790: Handle the RFE (Receive FIFO overflow
 Error) interrupt
Date: Wed, 31 Jul 2013 00:41:10 +0400
Message-ID: <51F824E6.9080006@cogentembedded.com>
References: <1375142928-17769-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>,
	linux-sh@vger.kernel.org, Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1375142928-17769-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 07/30/2013 04:08 AM, Laurent Pinchart wrote:

> The RFE interrupt is enabled for the r8a7790 but isn't handled,
> resulting in the interrupts core noticing unhandled interrupts, and
> eventually disabling the ethernet IRQ.
>
> Fix it by adding RFE to the bitmask of error interrupts to be handled
> for r8a7790.

> Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
> ---

    Laurent forgot to specify that the patch is for the net-next.git.

WBR, Sergei

