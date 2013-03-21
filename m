From: "devendra.aaru" <devendra.aaru@gmail.com>
Subject: tools/selftests: psock_fanout compiler errors
Date: Thu, 21 Mar 2013 18:07:13 +0530
Message-ID: <CAHdPZaMsvkwmbYm=-q_cynaScAr-vn0UfEPTzorb+ywKqU2a7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:58992 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758063Ab3CUMhO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 08:37:14 -0400
Received: by mail-wi0-f169.google.com with SMTP id hi8so1269792wib.0
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 05:37:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

when i do make -C tools/testing/selftests/.

I get

gcc -Wall -I../../../../usr/include/ -o psock_fanout psock_fanout.c
psock_fanout.c: In function =91test_control_single=92:
psock_fanout.c:239:23: error: =91PACKET_FANOUT_ROLLOVER=92 undeclared
(first use in this function)
psock_fanout.c:239:23: note: each undeclared identifier is reported
only once for each function it appears in
psock_fanout.c:240:11: error: =91PACKET_FANOUT_FLAG_ROLLOVER=92 undecla=
red
(first use in this function)
psock_fanout.c: In function =91test_control_group=92:
psock_fanout.c:264:11: error: =91PACKET_FANOUT_FLAG_ROLLOVER=92 undecla=
red
(first use in this function)
psock_fanout.c: In function =91main=92:
psock_fanout.c:368:44: error: =91PACKET_FANOUT_FLAG_ROLLOVER=92 undecla=
red
(first use in this function)
psock_fanout.c:372:23: error: =91PACKET_FANOUT_ROLLOVER=92 undeclared
(first use in this function)
make[1]: *** [psock_fanout] Error 1

i have the linux/if_packet.h file in /usr/include/ but i couldn't see
PACKET_FANOUT_ROLLOVER flag in that header.

I have a fedora 18 userspace

uname -a if you need it:

Linux localhost.localdomain 3.6.10-4.fc18.x86_64 #1 SMP Tue Dec 11
18:01:27 UTC 2012 x86_64 x86_64 x86_64 GNU/Linux

and the recent git head points to id in net-next is
e76d120b68d2e0f159ba999b1210920a5a0ed53d.

do i need to recompile the kernel and install kernel headers (i guess
kernel headers doesn't matter in this point)?

thanks,
