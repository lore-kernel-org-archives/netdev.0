From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 10GBE performance drop with net.ipv4.tcp_timestamps=0
Date: Wed, 20 Jun 2012 10:41:16 +0200
Message-ID: <1340181676.4604.838.camel@edumazet-glaptop>
References: <4FE0EA33.1000309@profihost.ag>
	 <1340141493.4604.773.camel@edumazet-glaptop>
	 <4FE17522.5050005@profihost.ag>
	 <1340176940.4604.801.camel@edumazet-glaptop>
	 <4FE1881B.7030800@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62749 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788Ab2FTIlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 04:41:21 -0400
Received: by bkcji2 with SMTP id ji2so5915733bkc.19
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 01:41:20 -0700 (PDT)
In-Reply-To: <4FE1881B.7030800@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 10:21 +0200, Stefan Priebe - Profihost AG wrote:
> Am 20.06.2012 09:22, schrieb Eric Dumazet:
> > On Wed, 2012-06-20 at 09:00 +0200, Stefan Priebe - Profihost AG wrote:
> >> Am 19.06.2012 23:31, schrieb Eric Dumazet:
> >> Before:
> >> http://pastebin.com/raw.php?i=1gVraWVc
> >>
> >> After:
> >> http://pastebin.com/raw.php?i=NSh8Y29s
> >
> > You have a lot of packet losses
> But this ONLY happens with tcp_timestamps=0.
> 

Yes, you already told that in subject line.

single tcp flow ?

You seem to have a switch or something that drops packets in this case.

You could try to rate limit to 9Gb/s and see if it is better.

Here, I roughly have same bandwidth with tcp_timestamps on or off, with
ixgbe cards and net-next kernels.
