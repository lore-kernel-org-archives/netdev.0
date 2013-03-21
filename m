From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: tools/selftests: psock_fanout compiler errors
Date: Thu, 21 Mar 2013 14:42:00 +0200
Message-ID: <CAEnQRZC6pJPmG0WAKRPx34AGTDBAaTkXif4Ufx-SpwYsPP5wvA@mail.gmail.com>
References: <CAHdPZaMsvkwmbYm=-q_cynaScAr-vn0UfEPTzorb+ywKqU2a7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "devendra.aaru" <devendra.aaru@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:46579 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753927Ab3CUMmB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 08:42:01 -0400
Received: by mail-wg0-f48.google.com with SMTP id 16so440139wgi.27
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 05:42:00 -0700 (PDT)
In-Reply-To: <CAHdPZaMsvkwmbYm=-q_cynaScAr-vn0UfEPTzorb+ywKqU2a7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 21, 2013 at 2:37 PM, devendra.aaru <devendra.aaru@gmail.com=
> wrote:
> Hello,
>
> when i do make -C tools/testing/selftests/.
>
> I get
>
> gcc -Wall -I../../../../usr/include/ -o psock_fanout psock_fanout.c
> psock_fanout.c: In function =91test_control_single=92:
> psock_fanout.c:239:23: error: =91PACKET_FANOUT_ROLLOVER=92 undeclared
> (first use in this function)
> psock_fanout.c:239:23: note: each undeclared identifier is reported
> only once for each function it appears in
> psock_fanout.c:240:11: error: =91PACKET_FANOUT_FLAG_ROLLOVER=92 undec=
lared
> (first use in this function)
> psock_fanout.c: In function =91test_control_group=92:
> psock_fanout.c:264:11: error: =91PACKET_FANOUT_FLAG_ROLLOVER=92 undec=
lared
> (first use in this function)
> psock_fanout.c: In function =91main=92:
> psock_fanout.c:368:44: error: =91PACKET_FANOUT_FLAG_ROLLOVER=92 undec=
lared
> (first use in this function)
> psock_fanout.c:372:23: error: =91PACKET_FANOUT_ROLLOVER=92 undeclared
> (first use in this function)
> make[1]: *** [psock_fanout] Error 1
>
> i have the linux/if_packet.h file in /usr/include/ but i couldn't see
> PACKET_FANOUT_ROLLOVER flag in that header.
>
> I have a fedora 18 userspace
>
> uname -a if you need it:
>
> Linux localhost.localdomain 3.6.10-4.fc18.x86_64 #1 SMP Tue Dec 11
> 18:01:27 UTC 2012 x86_64 x86_64 x86_64 GNU/Linux
>
> and the recent git head points to id in net-next is
> e76d120b68d2e0f159ba999b1210920a5a0ed53d.
>
> do i need to recompile the kernel and install kernel headers (i guess
> kernel headers doesn't matter in this point)?

Well :), check this [1].

thanks,
Daniel.

[1] http://www.spinics.net/lists/netdev/msg229812.html
