From: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Subject: Question about netns & AF_UNIX
Date: Thu, 27 May 2010 16:38:29 +0200
Message-ID: <AANLkTikBuXfzS-UIL7bDMvfpL5lx9gMqHTpGg-jrm5Zv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:64592 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757090Ab0E0Oib convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 10:38:31 -0400
Received: by vws9 with SMTP id 9so10063vws.19
        for <netdev@vger.kernel.org>; Thu, 27 May 2010 07:38:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, again a question about netns...

I seem to recall being able to use AF_UNIX sockets across network name
spaces, but I cannot reproduce that with a current kernel. Probably my
test was fubar (I've lost the script).

In any case: is a design decision to forbid this, even when the file
system is shared? I found some discussions from 2008, but I don't see
an agreement being reached...

I also wonder if filedescriptor passing thru ancilliary messages will
work (that is, with unix sockets that I've created before the netns
change).

Thanks

--=20
Mart=EDn Ferrari
