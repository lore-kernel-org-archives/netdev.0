From: Kevin Wilson <wkevils@gmail.com>
Subject: Socket options for different architectures (a short question)
Date: Thu, 25 Jun 2009 15:42:54 +0300
Message-ID: <55c333c0906250542r13d506b9i5bfcb4fd317a2852@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:39272 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbZFYMmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 08:42:53 -0400
Received: by bwz9 with SMTP id 9so1367414bwz.37
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2009 05:42:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, netdev list,

I have a short question about socket options:
why does each architecture has a list of the socket options
it supports in a separate socket.h header ? it seems to me that the list
of these options is identical (I did not verified this though)
Is there a case when some specific platform/platforms define socket
options in a different way ?
Is there a case when some platform supports only part of the socket
options ?
For example, for

SO_DEBUG,SO_REUSEADDR, SO_SNDBUF, etc, we have the same definitions in

 arch/ia64/include/asm/socket.h, arch/xtensa/include/asm/socket.h,
 arch/x86/include/asm/socket.h ,arch/powerpc/include/asm/socket.h and so on.

Regards,
 Kevin
