From: Faidon Liambotis <faidon@cube.gr>
Subject: Re: Remove Prism II support from Orinoco
Date: Tue, 13 Jun 2006 07:30:56 +0300
Message-ID: <448E3F80.5050103@cube.gr>
References: <20060610175010.GA4617@divinity> <20060610180850.GP7420@redhat.com> <20060611222719.GA13139@redhat.com> <20060611224054.GB13139@redhat.com> <20060611224954.GA2880@divinity> <20060612152434.GA14851@tuxdriver.com> <4807377b0606121710j5be6ce0fhac71b69bf4dce2c2@mail.gmail.com> <20060613042048.GA14824@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5-static.acn.gr ([213.5.41.24]:45244 "EHLO
	mail5-static.acn.gr") by vger.kernel.org with ESMTP id S932867AbWFMEbz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 00:31:55 -0400
Received: from mailslb.acn.gr (unknown [172.31.10.109])
	by mail5-static.acn.gr (Postfix) with ESMTP id B557B483FE3
	for <netdev@vger.kernel.org>; Tue, 13 Jun 2006 07:30:34 +0300 (EEST)
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060613042048.GA14824@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
>> my problem is that for my prism 2 adapter both drivers are loaded at
>> which point neither of them works.  I'm running FC5, and i have to
>> keep removing the orinoco*.ko files to keep them from loading, so I'm
>> all for this patch.
>>
> 
> use blacklist in module config to block one.
> Just put in /etc/modprobe.conf
> 
> blacklist orinoco
Unfortunately, that workaround doesn't work so well when you want to
have the ability to plug real orinoco (hermes) cards to your computer...
In other words and unless I'm missing something, there isn't currently a
way to have a Hermes card and a Prism II card both plugged in and working.

Regards,
Faidon
