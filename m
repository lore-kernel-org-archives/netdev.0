From: Michael Kerrisk <mtk.manpages@gmail.com>
Subject: Documenting UNIX domain autobind
Date: Sun, 10 Oct 2010 07:48:37 +0200
Message-ID: <AANLkTimtTazMmDvQFgASsVGa=AYvPZqUaUmyg5p7VVY1@mail.gmail.com>
Reply-To: mtk.manpages@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, mzxreary@0pointer.de
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:64029 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab0JJFtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Oct 2010 01:49:01 -0400
Received: by vws2 with SMTP id 2so354535vws.19
        for <netdev@vger.kernel.org>; Sat, 09 Oct 2010 22:49:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Tetsuo,

I'm the Linux man-pages mainatiner. I write to you because I see that
you recently (http://kerneltrap.org/mailarchive/linux-netdev/2010/8/30/6284106/thread#mid-6284106)
did some work patchiing Linux unix_autobind(), so you may know the
answer to this question. But, also others on the CC may know.

I recently noticed this feature in the kernel, and so added some
documentation to the unix(7) man page. That text reads as follows:

   Autobind Feature
       If a bind() call specifies addrlen as  sizeof(sa_family_t),  or
       the  SO_PASSCRED  socket option was specified for a socket that
       was not explicitly bound to an  address,  then  the  socket  is
       autobound  to  an  abstract address.  The address consists of a
       null byte followed by 5 bytes in the  character  set  [0-9a-f].
       (Thus, there is a limit of 2^20 autobind addresses.)

I think this text correctly documents the technical details (but let
me know if you see errors). What is lacking is an explanation of why
this feature exists. Is someone able to explain where this feature is
used and why?

thanks,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
