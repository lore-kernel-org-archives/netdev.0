From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/2] usbnet: don't clear urb->dev in tx_complete
Date: Thu, 22 Mar 2012 07:36:07 -0700
Message-ID: <20120322143607.GD19835@kroah.com>
References: <1332422558-6633-1-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, stable@kernel.org,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oliver@neukum.org>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:33416 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030637Ab2CVOgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 10:36:11 -0400
Received: by mail-gx0-f174.google.com with SMTP id e5so1789679ggh.19
        for <netdev@vger.kernel.org>; Thu, 22 Mar 2012 07:36:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1332422558-6633-1-git-send-email-tom.leiming@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 22, 2012 at 09:22:38PM +0800, Ming Lei wrote:
> URB unlinking is always racing with its completion and tx_complete
> may be called before or during running usb_unlink_urb, so tx_complete
> must not clear urb->dev since it will be used in unlink path,
> otherwise invalid memory accesses or usb device leak may be caused
> inside usb_unlink_urb.
> 
> Cc: stable@kernel.org
> Cc: Alan Stern <stern@rowland.harvard.edu>
> Cc: Oliver Neukum <oliver@neukum.org>
> Signed-off-by: Ming Lei <tom.leiming@gmail.com>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
