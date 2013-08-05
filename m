From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH net] net: mlx5: fix sizeof usage in health_care's
 reg_handler
Date: Mon, 5 Aug 2013 09:33:34 +0300
Message-ID: <20130805063334.GA22386@mtldesk30>
References: <1375438577-30933-1-git-send-email-dborkman@redhat.com>
 <20130802.151132.539136654627638979.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dborkman@redhat.com, netdev@vger.kernel.org, ogerlitz@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:43087 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817Ab3HEGdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 02:33:42 -0400
Received: by mail-we0-f170.google.com with SMTP id w60so2140467wes.29
        for <netdev@vger.kernel.org>; Sun, 04 Aug 2013 23:33:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130802.151132.539136654627638979.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 02, 2013 at 03:11:32PM -0700, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Fri,  2 Aug 2013 12:16:17 +0200
> 
> > Therefore, I strongly assume sizeof(*health->health) is being meant
> > to be passed as an argument. Interestingly, there are actually no

Daniel, you're fix is correct. I meant to pass the size of the struct
and not the size of the pointer.

> > in-tree users of mlx5_[un]register_health_report_handler(), but some
> > debugging modules might want to know the correct size instead.
> 
> I want these hooks and infrastructure removed immediately.
> 
> If there are no in-tree users there is no reason for them to
> exist at all.
> 

Hi Dave,
the intention here was to allow other module, if they so wish, to get
notified of any problems detected at the device. I understand that you
don't like this but is there another way to handle this requirement
which will be accepted?
