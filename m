From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: kernel: TKIP: replay detected:
Date: Mon, 25 Sep 2006 15:10:33 -0500
Message-ID: <451837B9.8060802@lwfinger.net>
References: <20060924104053.GA6645@frodo.home.lxtec.de> <20060925144954.GC16949@tuxdriver.com> <ef99oo$4jb$3@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:46014 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750914AbWIYUKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 16:10:40 -0400
To: Matthieu CASTET <castet.matthieu@free.fr>
In-Reply-To: <ef99oo$4jb$3@sea.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthieu CASTET wrote:
> Hi,
> 
> On Mon, 25 Sep 2006 10:50:00 -0400, John W. Linville wrote:
> 
>> On Sun, Sep 24, 2006 at 12:40:53PM +0200, Elimar Riesebieter wrote:
>>
>>> My sylog is filled up with thousands of:
>>> Sep 21 18:18:00 aragorn kernel: TKIP: replay detected: \
>>> STA=XX:XX:BB:LL:KK:00 previous TSC 00000000BLAa received TSC 00000000BLAa
>>> Sep 21 18:18:29 aragorn kernel: printk: 62 messages suppressed.
>> Opinion seems to be running that these messages are useless and should
>> be removed.  Anyone disagree?
>>
> They could be useful for debugging.
> 
> Instead of removing them, enable them when a DEBUG flags is enabled.

What condition do they indicate when the two are equal? As you probably saw, I sent a patch that 
disables them in that case, but still print the message when received < previous. Would that be 
acceptable?

Larry
