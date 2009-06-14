From: Paul Martin <srucnoc@gmail.com>
Subject: TCP partial write
Date: Sun, 14 Jun 2009 21:52:07 +0200
Message-ID: <394b5e260906141252g56d4275k185230f724b842ac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f207.google.com ([209.85.220.207]:50383 "EHLO
	mail-fx0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbZFNT7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2009 15:59:25 -0400
Received: by fxm3 with SMTP id 3so217072fxm.37
        for <netdev@vger.kernel.org>; Sun, 14 Jun 2009 12:59:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is it possible that a (non-blocking) TCP write(2) will write a number
of bytes not multiple of the machine word size? i.e., could a write
request for 4 bytes return 2?

Also is this an OS-dependent behavior or there is a spec for it? (I
could find atomic guarantees for pipes and datagram sockets but not
for TCP)

Thanks,
Paul
