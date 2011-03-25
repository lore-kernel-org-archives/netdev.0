From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Subject: disabling ipv6 (when ipv6 module is already loaded or built in)
Date: Fri, 25 Mar 2011 18:17:04 +0100
Message-ID: <201103251817.04583.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:49977 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752894Ab1CYRRJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 13:17:09 -0400
Received: by ewy4 with SMTP id 4so576661ewy.19
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2011 10:17:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

There are two options for disabling some ipv6 functionality in ipv6 mod=
ule -=20
disable and disable_ipv6. The second option is also available as sysctl=
 and=20
can be switched runtime.

=46irst is nicer because it also prevents apps from creating sockets by=
 using=20
socket(AF_INET6, ...). Various apps use AF_INET6 socket creation to det=
erine=20
if ipv6 is supported on the system. Unfortunately "disable" one doesn't=
 exist=20
as sysctl and this is a problem.

Is it possible to make "disable" sysctl option, too? Currently there is=
 no=20
runtime way to disable ipv6 (or I'm unaware of such way).

Thanks,
--=20
Arkadiusz Mi=C5=9Bkiewicz        PLD/Linux Team
arekm / maven.pl            http://ftp.pld-linux.org/
