From: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Subject: Problem with tun driver
Date: Thu, 16 Sep 2010 10:30:42 +0200
Message-ID: <AANLkTinzLJia4WV-GUse0sX=3Ht8DrD-vVd3YkxUE8xO@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@aristanetworks.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:49127 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711Ab0IPIam convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 04:30:42 -0400
Received: by iwn5 with SMTP id 5so869865iwn.19
        for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 01:30:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(copying Eric as he seems to have been writing patches for tun to work
with netns)

Hello,

I am seeing a strange behaviour with the TUN driver when using it
inside a network name space, hope that somebody can help me...

I still couldn' t reproduce this problem outside of my program, so it
complicates things more. What I am doing is creating a tap device,
moving it into a namespace and then passing the filedescriptor to
another process which in turn starts reading from it.

=46rom strace I see that many reads succeed (Ipv6 autoconfig and arp
requests), and at some point, read returns EBADF. I don't see the
other processes doing anything suspicious on it at the same time. From
reading the kernel sources, it seems to be failing the call to
tun_get(), but I don' t understand how that could be happening...

Any pointers?

Thanks

--=20
Mart=EDn Ferrari
