From: David Newall <davidn@davidnewall.com>
Subject: Re: What causes these TCP packet getting lost in linux kernel
Date: Mon, 14 Apr 2014 18:09:24 +0930
Message-ID: <534B9EBC.4000606@davidnewall.com>
References: <CAMRd1sXbgcGQuBKd6b-wwkrsqgh_4QicfyR=1hh+TqyYUjYHFA@mail.gmail.com>	<1397212866.16584.93.camel@edumazet-glaptop2.roam.corp.google.com>	<CAMRd1sUk_-gtOOgf2dPU_mpgCugDE2F82Te5arnhi+8-uPgm0g@mail.gmail.com>	<CAJzFV35Z9f-73of0vq2bhUZbN++17cuexcQV4SSSvqJXNyKnRQ@mail.gmail.com>	<1397331172.4222.8.camel@edumazet-glaptop2.roam.corp.google.com> <CAMRd1sV_ZzgFF8a2D=CsugHPHrNY=ifV1F46bKVwNSP9FvNPUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: chptx y <chptxy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hawking.rebel.net.au ([203.20.69.83]:51451 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbaDOEUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 00:20:53 -0400
In-Reply-To: <CAMRd1sV_ZzgFF8a2D=CsugHPHrNY=ifV1F46bKVwNSP9FvNPUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's interesting that all of the packets from source port 34865 to 
destination port 80 have invalid checksums.  The hint, that it could be 
a TCP offload engine, doesn't sound entirely believable because some 
value is being calculated and stored, not just a fixed or random value; 
and as the destination is port 80, I'm guessing that these the packets 
from your Android device, which probably doesn't have a TCP offload engine.
