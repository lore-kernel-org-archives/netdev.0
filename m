From: Amin Azez <azez@ufomechanic.net>
Subject: Re: e100 breakage located
Date: Sat, 09 Dec 2006 09:17:07 +0000
Message-ID: <457A7F13.6050002@ufomechanic.net>
References: <45641A4E.6020505@ufomechanic.net> <4807377b0611301134q33d1cd78l5a1f2eda33da21bc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Michael.ODonnell@stratus.com,
	NetDEV list <netdev@vger.kernel.org>,
	Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchor-post-35.mail.demon.net ([194.217.242.85]:1512 "EHLO
	anchor-post-35.mail.demon.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936563AbWLIJRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 04:17:00 -0500
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0611301134q33d1cd78l5a1f2eda33da21bc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:
> sorry for the delay, your mail got marked as spam.  In the future
> please copy networking issues to netdev@vger.kernel.org, and be sure
> to copy the maintainers of the driver you're having problems with
> (they are in the MAINTAINERS file)
>
> On 11/22/06, Amin Azez <azez@ufomechanic.net> wrote:
>> I notice a patch in 2005 from Micahel O'Donnel to the e100.c driver has
>> stopped auto-crossover working on some e100 devices we use.
>>
>> On one system the auto-negotiation was restored by commenting out:
>> (nic->mac == mac_82551_10) in function e100_phy_init where the MDI/MDI-X
>> is disabled.
>
> are you sure that patch did that?  What version of e100 are you using?
> we've since enabled MDI-X on most parts with this patch:
> http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=60ffa478759f39a2eb3be1ed179bc3764804b2c8;hp=09e590e5d5a93f2eaa748a89c623258e6bad1648 
>
>
> Please try the latest kernel or the latest e100 available from 
> e1000.sf.net
> if that doesn't work we'll need to know what kernel are you using?
Let me have another check and get back to you.

It will be at least a week though.

Thanks for your response.

Sam
