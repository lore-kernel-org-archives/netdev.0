From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] firmware: convert acenic driver to request_firmware()
Date: Wed, 18 Jun 2008 12:26:07 -0400
Message-ID: <4859371F.8090404@garzik.org>
References: <1213608300.26255.665.camel@pmac.infradead.org>	 <4856CE43.4020706@garzik.org>	 <1213652749.26255.842.camel@pmac.infradead.org>	 <4856E50C.5050908@garzik.org>	 <1213699220.26255.977.camel@pmac.infradead.org> <1213805681.26255.1312.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <jes@trained-monkey.org>, netdev@vger.kernel.org,
	jaswinder@infradead.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52719 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750853AbYFRQ0L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 12:26:11 -0400
In-Reply-To: <1213805681.26255.1312.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse wrote:
> I believe you didn't respond to this, but just spouted the same
> complaint at another patch which was posted for review, without even
> seeming to have _looked_ at the part of that patch which really needed
> reviewing.
> 
> This has needed doing for a long time, and I've finally got off my
> posterior and started working on it. If you wanted it done precisely
> your way, you could always have done it yourself. As it is, we have a
> minor disagreement about some of the details, but it still needs doing.
> And since it still seems to be me doing it and not you, I'm still doing
> it the way I believe is best.


So, if you get an unhappy review, the reviewer must do your work for 
you?  That doesn't work for university students, and that doesn't fly here.

We are in the part of the Linux kernel coding process called 'taking 
feedback'.

The onus is on YOU to make your work friendly to both users and developers.

You can do whatever you please, but if its not friendly to Linux users 
(our customers) or Linux developers, it's mostly dead in the water. 
Those are my concerns, which you repeatedly fail to address.

For Pete's sake, you haven't even been able to admit the obvious:  these 
patches have a major, major chance of producing a non-working driver for 
users.

Your patch and your goal mean nothing if Linux users wind up having to 
jump through a dozen new hoops, just to ensure that a driver working 
yesterday continues to work today.  That's just plain bad engineering, 
no matter how noble the goal.

	Jeff


