From: Volkan YAZICI <volkan.yazici@gmail.com>
Subject: Re: How To Temporarily Suspend Network Traffic
Date: Tue, 01 Feb 2011 20:12:47 +0200
Message-ID: <87ipx335e1.fsf@alamut.ozu.edu.tr>
References: <87d3nbakwx.fsf@alamut.ozu.edu.tr> <4D4843B0.1090803@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52714 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752436Ab1BATrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 14:47:33 -0500
Received: by wyb28 with SMTP id 28so7071983wyb.19
        for <netdev@vger.kernel.org>; Tue, 01 Feb 2011 11:47:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 01 Feb 2011 09:32:32 -0800, Rick Jones writes:
> Out of not quite idle curiousity, what are you trying to accomplish?

I'm trying to implement a coarse-grained soft-TDMA (Time Division
Multiple Access) among devices in a Wi-Fi network. (Coarse-grained, that
is, compared to a hardware implementation.) Assuming that device clocks
are in sync via NTP, I will figure out the granularity I can achieve
with soft-TDMA.

> Instead of using tc to set a zero rate, you could perhaps try using tc
> to set a delay? If it doesn't offer microseconds of delay, pehaps
> setting a delay and then eliminating it after your own pause will do
> what you want - depends of course on what it is you really want.

Thanks for the advice. I'll check this out and see what I can do.

> Your saying you wanted microsecond granularity suggests you don't want
> to suspend traffic for very long?

I want to figure out the smallest delay that I can achieve in a periodic
manner. (E.g., freeze the traffic for 200us, continue without
interruption for 800us, and freeze the traffic again for another 200us,
etc.) Pay attention that, an undeterministic delay somewhere in between
1000us is not something I prefer, I must be able to determine the point
in time where delay will appear -- ofcourse, with some error margin.


Regards.
