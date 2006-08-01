From: Jamal Hadi Salim <hadi@cyberus.ca>
Subject: Re: Re[2]: e1000 speed/duplex error
Date: Tue, 01 Aug 2006 08:22:00 -0400
Message-ID: <1154434920.5170.100.camel@jzny2>
References: <1301563340.20060801141827@mail.ru>
	 <9929d2390608010420t60bd44d7o4e522c6edc0a677e@mail.gmail.com>
	 <595776532.20060801160328@mail.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <tarbal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:65182 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751265AbWHAMWC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 08:22:02 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1G7tG8-0000ZY-PG
	for netdev@vger.kernel.org; Tue, 01 Aug 2006 08:22:04 -0400
To: a1 <a1k@mail.ru>
In-Reply-To: <595776532.20060801160328@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-01-08 at 16:03 +0400, a1 wrote:

> I thought the common behavior is that if one side force any particular
> parameter, other side should "sense" that and go to that mode too.
> 

You _cannot_ depend on that behavior at all. IOW, if one side is not
forced the other side's setting is undefined and falls back to whatever
that side defines as "default"

> In current case there is misunderstanding - one side (linux box)
> reports 100/FD and other (switch) reports 100/HD.
> 
> Maybe I don't understand something...

You must force both sides for predictable behavior. I would say that
doing HD as default is more common. So Linux may need to change just
that one bit.

cheers,
jamal


