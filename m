From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] USB: remove info() macro from usb network drivers
Date: Wed, 22 Oct 2008 09:16:03 -0700
Message-ID: <20081022161603.GC29489@kroah.com>
References: <20081010051624.GA32711@kroah.com> <48FF094C.6040806@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:51642 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757230AbYJVQT1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 12:19:27 -0400
Content-Disposition: inline
In-Reply-To: <48FF094C.6040806@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2008 at 07:06:52AM -0400, Jeff Garzik wrote:
> Greg KH wrote:
>> From: Greg Kroah-Hartman <gregkh@suse.de>
>> USB should not be having it's own printk macros, so remove info() and
>> use the system-wide standard of dev_info() wherever possible.
>> Cc: Jeff Garzik <jgarzik@pobox.com>
>> Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
>> ---
>> Jeff, this has been in the USB tree for a few months now, sorry for not
>> sending it to you sooner.  I can easily keep it in my tree and send it
>> to Linus for this merge if you want me to, or you can take it in your
>> tree, which ever you want me to do.
>> thanks,
>> greg k-h
>>  drivers/net/irda/kingsun-sir.c  |    3 ++-
>>  drivers/net/irda/ks959-sir.c    |    3 ++-
>>  drivers/net/irda/ksdazzle-sir.c |    3 ++-
>>  drivers/net/irda/stir4200.c     |    8 +++++---
>>  drivers/net/usb/catc.c          |    3 ++-
>>  drivers/net/usb/kaweth.c        |   19 ++++++++++---------
>>  drivers/net/usb/rtl8150.c       |   15 +++++++++------
>>  7 files changed, 32 insertions(+), 22 deletions(-)
>
> post-vacation ACK, feel free to send via your tree if you wish

Already did, hope your vacation was nice :)

thanks,

greg k-h
