From: chptx y <chptxy@gmail.com>
Subject: Re: What causes these TCP packet getting lost in linux kernel
Date: Mon, 14 Apr 2014 17:20:08 +0800
Message-ID: <CAMRd1sWa70D3Cjx74jC8g2fJKXho=okrpu+HfsZmu77-70c4DQ@mail.gmail.com>
References: <CAMRd1sXbgcGQuBKd6b-wwkrsqgh_4QicfyR=1hh+TqyYUjYHFA@mail.gmail.com>
	<1397212866.16584.93.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMRd1sUk_-gtOOgf2dPU_mpgCugDE2F82Te5arnhi+8-uPgm0g@mail.gmail.com>
	<CAJzFV35Z9f-73of0vq2bhUZbN++17cuexcQV4SSSvqJXNyKnRQ@mail.gmail.com>
	<1397331172.4222.8.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAMRd1sV_ZzgFF8a2D=CsugHPHrNY=ifV1F46bKVwNSP9FvNPUw@mail.gmail.com>
	<534B9EBC.4000606@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Newall <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:42838 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753437AbaDNJUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 05:20:08 -0400
Received: by mail-ob0-f177.google.com with SMTP id vb8so493944obc.36
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 02:20:08 -0700 (PDT)
In-Reply-To: <534B9EBC.4000606@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i don't know why, no matter I capture packets on my Ubuntu PC or
Android device with tcpdump,  open the output file with wireshark, all
output packets are marked with "incorrect checksum", but it seems that
this problem don't affect  subsequent packets interaction. why?

2014-04-14 16:39 GMT+08:00 David Newall <davidn@davidnewall.com>:
> It's interesting that all of the packets from source port 34865 to
> destination port 80 have invalid checksums.  The hint, that it could be a
> TCP offload engine, doesn't sound entirely believable because some value is
> being calculated and stored, not just a fixed or random value; and as the
> destination is port 80, I'm guessing that these the packets from your
> Android device, which probably doesn't have a TCP offload engine.
