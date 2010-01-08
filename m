From: Dragoslav Zaric <dragoslav.zaric.kd@gmail.com>
Subject: Re: Socket Server breaks after 1000 client requests
Date: Fri, 8 Jan 2010 18:24:22 +0100
Message-ID: <2d05c4581001080924j159193c4ve45c8db14f89f8cf@mail.gmail.com>
References: <2d05c4580912311111w6abaa007y5d212dd8fbde24d9@mail.gmail.com>
	 <4B3CF9EC.9070103@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:51738 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273Ab0AHRYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 12:24:24 -0500
Received: by bwz27 with SMTP id 27so12289430bwz.21
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2010 09:24:22 -0800 (PST)
In-Reply-To: <4B3CF9EC.9070103@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Ben,

The error was definitely in my code. I used c++ functions for send and receive.
Now I am using write() and read() system calls to write and read
directly to sockets and
it works flawlessly ;)

When I am sending 100 000 messages in loop from client to server it goes for few
seconds.

regards,

dragoslav zaric
