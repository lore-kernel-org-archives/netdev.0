From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: optimize Berkeley Packet Filter (BPF) processing
Date: Mon, 21 Jun 2010 10:15:33 +0800
Message-ID: <AANLkTinNDMrpDUxQGjQTReuN7EyIPYNnpfO77jRFIjM7@mail.gmail.com>
References: <1277003136-5522-1-git-send-email-hagen@jauu.net>
	<20100619221611.784f7dbc@nehalam> <20100620095019.GA32223@nuttenaction>
	<20100620.150928.245399526.davem@davemloft.net> <20100620215743.GA4036@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:45721 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757600Ab0FUCPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jun 2010 22:15:54 -0400
Received: by vws3 with SMTP id 3so349468vws.19
        for <netdev@vger.kernel.org>; Sun, 20 Jun 2010 19:15:53 -0700 (PDT)
In-Reply-To: <20100620215743.GA4036@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 21, 2010 at 5:57 AM, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
> * David Miller | 2010-06-20 15:09:28 [-0700]:
>
>>I think from this perspective, the change is fine too, nothing visible
>>to the user is being changed here.
>
> Fine! I have a fundamental question: can we start to use a C language
> extension, known as "Labels as Values" in the kernel? I checked this and at
> least gcc, llvm and icc support this extension (btw: c1x[1] don't mention
> this):
>

FYI: FreeBSD goes even further, and its BPF implementation exploits
JIT in two architectures: i386 and amd64.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
