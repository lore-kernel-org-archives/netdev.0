From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] TTY: ircomm, use GFP_KERNEL in ircomm_open()
Date: Fri, 5 Apr 2013 14:15:00 -0700
Message-ID: <20130405211500.GA14617@kroah.com>
References: <1365195727-24780-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Mathias Krause <minipli@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:54871 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162478Ab3DEVPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 17:15:03 -0400
Received: by mail-pd0-f177.google.com with SMTP id u11so2222038pdi.36
        for <netdev@vger.kernel.org>; Fri, 05 Apr 2013 14:15:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1365195727-24780-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 05, 2013 at 11:02:07PM +0200, Mathias Krause wrote:
> Hi Greg,
> 
> I'm unsure if you or Dave should take that one as it's for one a TTY
> patch but also living under net/. So I'm uncertain and let you decide!

If Dave want to take it, it's fine with me:

> -- >8 --
> Subject: [PATCH] TTY: ircomm, use GFP_KERNEL in ircomm_open()
> 
> We're clearly running in non-atomic context as our only call site is
> able to call wait_event_interruptible(). So we're safe to use GFP_KERNEL
> here instead of GFP_ATOMIC.
> 
> Signed-off-by: Mathias Krause <minipli@googlemail.com>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
