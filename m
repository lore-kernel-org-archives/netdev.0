From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] atl1 causes lockup/reboot on resume from STR
Date: Sat, 11 Sep 2010 22:47:38 +0200
Message-ID: <4C8BEAE9.4030907@gmail.com>
References: <20100911131209.GA3756@nb-core2.darkstar.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Luca Tettamanti <kronos.it@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:64753 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161Ab0IKUro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Sep 2010 16:47:44 -0400
Received: by ewy23 with SMTP id 23so2293168ewy.19
        for <netdev@vger.kernel.org>; Sat, 11 Sep 2010 13:47:43 -0700 (PDT)
In-Reply-To: <20100911131209.GA3756@nb-core2.darkstar.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Luca Tettamanti wrote, On 09/11/2010 03:12 PM:

> Hello,
> I'm having troubles with atl1 driver (notebook is an Asus F3Sa): during
> the resume from S3 the machine either locks up or reboots.
> However I was also able to get a (partial) stack trace involving
> atl1_resume (the rest of the trace scrolled off screen) and a message
> about a recursive fault, followed by a hard lock up.
> If I rmmod atl1 before suspending, the machine comes back fine; I don't
> known whether this is a regression or not, until recently the radeon
> driver didn't survive S3 so I didn't even try suspending to RAM...
> I'm currently running -git current (2.6.36-rc3-00396-gbe6200a), but I've
> gone back till 2.6.32 without any succcess.
> I've no idea on how to debug this, the machine does not have a serial
> port (and netconsole obviously does not help)... help :)

Here is an example of kernel photography with an interesting hint
by Andrew Morton: 
https://bugzilla.kernel.org/show_bug.cgi?id=16626


Jarek P.
