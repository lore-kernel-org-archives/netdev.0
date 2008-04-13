From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [NET] [ISDN]: Do not validate ISDN net device address
 prior to interface-up
Date: Sun, 13 Apr 2008 10:26:49 +0200
Message-ID: <4801C3C9.4070408@trash.net>
References: <1207839617.4311.6.camel@compaq.thuisdomein> <4801A85F.8090906@trash.net> <4801BF1C.30207@gmail.com> <4801BEB4.6090909@trash.net> <20080413082738.GA2788@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Bolle <pebolle@tiscali.nl>, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de, Jeff Garzik <jgarzik@redhat.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36945 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbYDMIaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 04:30:16 -0400
In-Reply-To: <20080413082738.GA2788@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Sun, Apr 13, 2008 at 10:05:08AM +0200, Patrick McHardy wrote:
> ...
>   
>> In my opinion a proper error code like EADDRNOTAVAIL is enough, we
>> have thousands of checks that might make things fail, should we
>> add a printk to every one of those?
>>     
>
> IMHO yes - but only when "the functionality" is changed causing
> regressions like this.

This one is simply a bug, not a functional change.

>  BTW, I've assisted some similar case in
> bugzilla, and I guess users will still ask for an explanation after
> this error code change.
>   

Well, I don't have particulary strong feelings about this, but
I think adding a printk to one out of thousands of possible
errors won't help much.

What would be nice is some extended error reporting for netlink.

