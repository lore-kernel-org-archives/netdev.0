From: Luca Tettamanti <kronos.it@gmail.com>
Subject: Re: [BUG] atl1 causes lockup/reboot on resume from STR
Date: Tue, 14 Sep 2010 15:59:04 +0200
Message-ID: <AANLkTinqRimgYh_ueYdwcfyHBLT546obyYFQHJvOkQjc@mail.gmail.com>
References: <20100911131209.GA3756@nb-core2.darkstar.lan>
	<4C8BEAE9.4030907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:33119 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753777Ab0INN7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 09:59:05 -0400
Received: by pzk34 with SMTP id 34so2429881pzk.19
        for <netdev@vger.kernel.org>; Tue, 14 Sep 2010 06:59:05 -0700 (PDT)
In-Reply-To: <4C8BEAE9.4030907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 11, 2010 at 10:47 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
[...]
>> I've no idea on how to debug this, the machine does not have a serial
>> port (and netconsole obviously does not help)... help :)
>
> Here is an example of kernel photography with an interesting hint
> by Andrew Morton:
> https://bugzilla.kernel.org/show_bug.cgi?id=16626

Thanks for the tip, however the stack trace is extremely elusive: the
machine keeps resetting.
Anyway I've managed to track it down the old way (sticking printk
everywhere and commenting out random pieces of code :P)

Luca
