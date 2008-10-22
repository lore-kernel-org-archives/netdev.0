From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] USB: remove info() macro from usb network drivers
Date: Wed, 22 Oct 2008 07:06:52 -0400
Message-ID: <48FF094C.6040806@pobox.com>
References: <20081010051624.GA32711@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45703 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750785AbYJVLG5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 07:06:57 -0400
In-Reply-To: <20081010051624.GA32711@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH wrote:
> From: Greg Kroah-Hartman <gregkh@suse.de>
> 
> USB should not be having it's own printk macros, so remove info() and
> use the system-wide standard of dev_info() wherever possible.
> 
> Cc: Jeff Garzik <jgarzik@pobox.com>
> Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> ---
> Jeff, this has been in the USB tree for a few months now, sorry for not
> sending it to you sooner.  I can easily keep it in my tree and send it
> to Linus for this merge if you want me to, or you can take it in your
> tree, which ever you want me to do.
> 
> thanks,
> 
> greg k-h
> 
>  drivers/net/irda/kingsun-sir.c  |    3 ++-
>  drivers/net/irda/ks959-sir.c    |    3 ++-
>  drivers/net/irda/ksdazzle-sir.c |    3 ++-
>  drivers/net/irda/stir4200.c     |    8 +++++---
>  drivers/net/usb/catc.c          |    3 ++-
>  drivers/net/usb/kaweth.c        |   19 ++++++++++---------
>  drivers/net/usb/rtl8150.c       |   15 +++++++++------
>  7 files changed, 32 insertions(+), 22 deletions(-)

post-vacation ACK, feel free to send via your tree if you wish


