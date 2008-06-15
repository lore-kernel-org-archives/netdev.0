From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM] iphase: BUG: sleeping function called from invalid context
Date: Sun, 15 Jun 2008 10:47:34 -0400
Message-ID: <200806151447.m5FElY6N009124@cmf.nrl.navy.mil>
References: <48551280.1090706@dti2.net>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:44348 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757812AbYFOOrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 10:47:53 -0400
In-reply-to: <48551280.1090706@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <48551280.1090706@dti2.net>,"Jorge Boncompte [DTI2]" writes:
>> the lock is necessary to prevent multiple cards from modifying iadev_count
>> at the wrong time since iadev_count is incremented and decremented.
>> it might be simpler to just make a local copy of iadev_count and just
>> always increment iadev_count.  if you fail to init a particular card,
>> you will just leave a hole in ia_dev[].  something like the attached.
>
>	I thought that device initialization inside a driver is serialized. isn't it?

i honestly dont know.  even if it is serialized, that code is just
hideous.  if you had a system with hotplug support, it wouldnt work right.

>	I have a patch that removes iadev and iadev_count enterely that i did not sent because i thought it wouldn't be 
>considered a bug fix. I'll sent it this week.

i would certainly prefer that version.  no matter, how you fix the
problem it is a bug fix.
