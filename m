From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v2, resend] gianfar: don't duplicate gfar_error()
Date: Sat, 17 Feb 2007 15:27:30 -0500
Message-ID: <45D76532.2090508@garzik.org>
References: <200702151656.01313.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47752 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751762AbXBQU1c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 15:27:32 -0500
In-Reply-To: <200702151656.01313.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergei Shtylyov wrote:
> It was hardly necessary to repeat most of the code from gfar_error() in
> gfar_interrupt(), especially having some inconsistencies between the two.
> So, make the gfar_interrupt() just call gfar_error(), and not acknowledge
> the interrupts itself as gfar_{receive/transmit/error}() do it anyway.
> While at it, also clarify/cleanup debug messages in gfar_error()...
> 
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
> 
> ---
> The patch survived netperf stressing on MPC8540ADS realtime kernel. :-)
> 
> Sorry, forgot to remove the obsolete regs argument from gfar_error() call,
> call, so the previous version wasn't even compilable -- I've tested the patch
> in the older kernel. Resending now with better placed comments which you won't
> have to edit out... :-<
> 
>  drivers/net/gianfar.c |   85 ++++++++------------------------------------------
>  1 files changed, 15 insertions(+), 70 deletions(-)

applied.  thanks for resending with your comments moved after the "---" 
terminator


