From: Chetan Loke <chetanloke@gmail.com>
Subject: rps and pvdrivers
Date: Fri, 3 Sep 2010 15:49:17 -0400
Message-ID: <AANLkTimrHh1ZasO=GWUOT9YJbu2EqeAx6OkRXPUSSNJ6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, pv-drivers@vmware.com, therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61727 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752124Ab0ICTtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 15:49:18 -0400
Received: by fxm13 with SMTP id 13so1428854fxm.19
        for <netdev@vger.kernel.org>; Fri, 03 Sep 2010 12:49:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I just tried kernel-2.6.35-0.57.rc6.git1.fc14.x86_64.rpm because
ksoftirqd was consuming 100% cpu under high packet load(on a 10G
vNIC). Now with the above combo the vNIC on the monitoring interface
virtually receives 'zero' interrupts.
Do I have to configure anything manually? Things work fine with 2.6.33
and I can capture 250K+ packets but I can't use it on a 10G NIC. I'm
going to try the stock 2.6.35.4 to see if I get the same results.

Is anyone else seeing similar issues?


Chetan Loke
