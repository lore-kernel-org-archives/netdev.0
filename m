From: MK <stardust496@gmail.com>
Subject: empty ack packets
Date: Fri, 10 Sep 2010 01:12:44 -0400
Message-ID: <AANLkTimkvDsqY==1JQRhH54+P7yAzFX4omYN0r9+_mi=@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:56514 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903Ab0IJFMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 01:12:45 -0400
Received: by vws3 with SMTP id 3so2138668vws.19
        for <netdev@vger.kernel.org>; Thu, 09 Sep 2010 22:12:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello list,

I am looking at a tcpdump and I see that very very frequently, after
receiving a segment, my tcp is sending an empty ack back in a matter
of several (around 20 - 50) microseconds. And then after several more
microseconds, my tcp is sending some valid outgoing data. I am trying
to understand why it decided to send an empty ack back when that ack
could potentially have been delayed by microseconds and get
piggybacked on the outgoing data.

>From the code, it appears that the delayed ack timeout is 40 millisecs
so it is likely not the delack timer that is causing this. (And I do
not have the quickack option)

This is RHEL5 (2.6.18) kernel.

Does anybody have an idea as to what is happening?

Thanks a lot!!
