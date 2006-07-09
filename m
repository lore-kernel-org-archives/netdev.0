From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Sun, 09 Jul 2006 19:06:59 -0400
Message-ID: <1152486419.5124.139.camel@jzny2>
References: <20060701112833.GS14627@postel.suug.ch>
	 <1151760901.5093.141.camel@jzny2> <20060708105451.GG14627@postel.suug.ch>
	 <1152368076.5272.39.camel@jzny2> <20060708234602.GH14627@postel.suug.ch>
	 <1152449536.5124.31.camel@jzny2> <20060709133327.GK14627@postel.suug.ch>
	 <1152453796.5124.70.camel@jzny2> <20060709141933.GM14627@postel.suug.ch>
	 <1152457232.5124.127.camel@jzny2>  <20060709155405.GO14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:20204 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932520AbWGIXHC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 19:07:02 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FziMl-0003RP-0d
	for netdev@vger.kernel.org; Sun, 09 Jul 2006 19:07:07 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060709155405.GO14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-09-07 at 17:54 +0200, Thomas Graf wrote:

> Look at where dev->queue_lock is taken, whenever a qdisc or
> filter is added, modified or deleted the lock is taken. Using
> your approach packets get dropped while such an operation is
> taking place. 

True, this will be bad for devices that dont care about any of this
(looping etc).
Perhaps it may even have been a reason that held me back - i dont
remember and it doesnt matter.
So go ahead and submit a patch while keeping in mind the same reasoning
as above.

> Your approach is wrong.

And this is where we are going to go into a loop. Do you want to go that
path? I suggest we dont.

cheers,
jamal

