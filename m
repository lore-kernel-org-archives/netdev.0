From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: SO_REUSEPORT - can it be done in kernel?
Date: Thu, 27 Jan 2011 12:07:51 +0200
Message-ID: <AANLkTimDtaV=WhZUUEivg3_vEUeUk3_WQSs09h7USiUj@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:49283 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011Ab1A0KHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 05:07:51 -0500
Received: by pxi15 with SMTP id 15so232446pxi.19
        for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 02:07:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

How did you solved the issue regarding scaling TCP listeners?
I think SO_REUSEPORT proposed by patch [1] can be a good
start. Where there any follow ups?

Also, solving the problem in users pace can be an option. I want
to run multiple instances of a DNS server on a multi core system.
Any suggestions would be welcomed.

SO_REUSEPORT option seems to be already there [2]. Where
there any plans to have a kernel implementation?

thanks,
Daniel.

[1] http://amailbox.org/mailarchive/linux-netdev/2010/4/19/6274993
[2] http://lxr.linux.no/linux+v2.6.37/include/asm-generic/socket.h#L25
