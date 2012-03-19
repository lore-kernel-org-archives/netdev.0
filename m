From: Neal Cardwell <ncardwell@google.com>
Subject: Re: 3.0.23 WARNING: at net/ipv4/tcp_input.c:3375 tcp_ack+0x1d62/0x2030()
Date: Mon, 19 Mar 2012 13:39:38 -0400
Message-ID: <CADVnQynya96iG0cZjVGhtac2MP3AOBWODP7nUTMVhMd=6GWSOQ@mail.gmail.com>
References: <4F66EA0B.1080705@profihost.ag>
	<20120319161534.GC24487@kroah.com>
	<20120319161604.GA2972@kroah.com>
	<1332177220.9397.33.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Greg KH <greg@kroah.com>,
	Stefan Priebe - Profihost AG <s.priebe@profihost.ag>,
	stable@vger.kernel.org, Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:58510 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758038Ab2CSRjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 13:39:39 -0400
Received: by qcqw6 with SMTP id w6so1348816qcq.19
        for <netdev@vger.kernel.org>; Mon, 19 Mar 2012 10:39:38 -0700 (PDT)
In-Reply-To: <1332177220.9397.33.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 19, 2012 at 09:10:51AM +0100, Stefan Priebe - Profihost AG wrote:
> WARNING: at net/ipv4/tcp_input.c:3375 tcp_ack+0x1d62/0x2030()

I double-checked the warning, and indeed in the 3.0.23 tcp_input.c at

http://git.kernel.org/?p=linux/kernel/git/stable/linux-stable.git;a=blob;f=net/ipv4/tcp_input.c;h=ee08f11ff21a802faa8b32efc1eb312e479878d6;hb=bf6a68d2a214e07f7c0d6538e00e17b826714160#l3375

that line is:
  WARN_ON((int)tp->sacked_out < 0);

So this indeed looks like the known issue that is fixed by the commits
Eric mentions, which are in 3.0.25.

neal
