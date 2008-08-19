From: "=?KOI8-R?B?7MXPzsnEIODS2MXX?=" <leo@yuriev.ru>
Subject: Re: [r8169] patch for RTL8102 (5 new MAC/PHY)
Date: Tue, 19 Aug 2008 22:04:09 +0400
Message-ID: <1f9da0830808191104y3a7b0aan59c9655dc67264b4@mail.gmail.com>
References: <1f9da0830808190642yacb2aacv6517e2bb86a3706@mail.gmail.com>
	 <1f9da0830808190645o4ecf48b1i6f4d873db3c83e39@mail.gmail.com>
	 <48AAF967.4000902@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ivan Vecera" <ivecera@redhat.com>,
	"Francois Romieu" <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f29.google.com ([209.85.217.29]:42580 "EHLO
	mail-gx0-f29.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608AbYHSSEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 14:04:11 -0400
Received: by gxk10 with SMTP id 10so7255339gxk.13
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 11:04:10 -0700 (PDT)
In-Reply-To: <48AAF967.4000902@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/8/19 Ivan Vecera <ivecera@redhat.com>:
> The support for RTL8102 was added 2 days ago. See Francois's git tree
> in r8169-fixes branch.
> http://git.kernel.org/?p=linux/kernel/git/romieu/netdev-2.6.git;a=shortlog;h=r8169-fixes
Oh, yes :)

>> 2) simple: by RTL8169 datasheet 'rx-missed' counter is 24-bits width,
>> but not 32;
> interesting :-)

http://wiki.osdev.org/RTL8169, seek bottom of page for the link to
http://www.magnesium.net/~wpaul/rt/RTL8110S_8169S_DataSheet_1.3.pdf,
Datasheet for the RTL8169S and RTL8110S chpsets.

So, on page #15, can see:

004Ch-004Fh R/W MPC
Missed Packet Counter: This 24-bit counter indicates the number of
packets discarded due to Rx FIFO overflow. After a s/w reset, MPC
is cleared. Only the lower 3 bytes are valid.
When any value is written to MPC, it will be reset.

--
Leo Yuriev
