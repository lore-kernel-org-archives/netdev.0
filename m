From: Stefan Priebe <s.priebe@profihost.ag>
Subject: Re: 3.0.23 WARNING: at net/ipv4/tcp_input.c:3375 tcp_ack+0x1d62/0x2030()
Date: Mon, 19 Mar 2012 19:20:39 +0100
Message-ID: <AB9F1763-96B1-4AE4-8D94-73246EA08207@profihost.ag>
References: <4F66EA0B.1080705@profihost.ag> <20120319161534.GC24487@kroah.com> <20120319161604.GA2972@kroah.com> <1332177220.9397.33.camel@edumazet-glaptop> <CADVnQynya96iG0cZjVGhtac2MP3AOBWODP7nUTMVhMd=6GWSOQ@mail.gmail.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Greg KH <greg@kroah.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:60228 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1032372Ab2CSSUp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 14:20:45 -0400
In-Reply-To: <CADVnQynya96iG0cZjVGhtac2MP3AOBWODP7nUTMVhMd=6GWSOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 19.03.2012 um 18:39 schrieb Neal Cardwell <ncardwell@google.com>:

> On Mon, Mar 19, 2012 at 09:10:51AM +0100, Stefan Priebe - Profihost AG wrote:
>> WARNING: at net/ipv4/tcp_input.c:3375 tcp_ack+0x1d62/0x2030()
> 
> I double-checked the warning, and indeed in the 3.0.23 tcp_input.c at
> 
> http://git.kernel.org/?p=linux/kernel/git/stable/linux-stable.git;a=blob;f=net/ipv4/tcp_input.c;h=ee08f11ff21a802faa8b32efc1eb312e479878d6;hb=bf6a68d2a214e07f7c0d6538e00e17b826714160#l3375
> 
> that line is:
>  WARN_ON((int)tp->sacked_out < 0);
> 
> So this indeed looks like the known issue that is fixed by the commits
> Eric mentions, which are in 3.0.25.
> 
> neal

Perfect, thanks! 

Greg any ETA?

Stefan