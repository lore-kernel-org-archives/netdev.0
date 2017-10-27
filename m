From: =?UTF-8?Q?Holger_Hoffst=c3=a4tte?= <holger@applied-asynchrony.com>
Subject: Re: [PATCH] r8169: Add support for interrupt coalesce tuning (ethtool
 -C)
Date: Fri, 27 Oct 2017 14:43:02 +0200
Message-ID: <17a1d528-5127-e01d-d982-87be3b09cba5@applied-asynchrony.com>
References: <20171027102449.19756-1-kirr@nexedi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
        Hayes Wang <hayeswang@realtek.com>,
        Realtek linux nic maintainers <nic_swsd@realtek.com>,
        David Laight <David.Laight@ACULAB.COM>,
        =?UTF-8?Q?St=c3=a9phane_ANCELOT?= <sancelot@free.fr>,
        Eric Dumazet <edumazet@google.com>
To: Kirill Smelkov <kirr@nexedi.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail02.iobjects.de ([188.40.134.68]:60000 "EHLO
        mail02.iobjects.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752477AbdJ0MwP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 08:52:15 -0400
In-Reply-To: <20171027102449.19756-1-kirr@nexedi.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/17 12:24, Kirill Smelkov wrote:
> 
> Kirr: In particular with
> 
> 	ethtool -C <ifname> rx-usecs 0 rx-frames 0
> 
> now it is possible to disable RX delays when NIC usage requires low-latency.
> 
> See this thread for context:
> 
> 	https://www.spinics.net/lists/netdev/msg217665.html

(snip)

> We have this patch running in our testing setup for 1 months already
> without any issues observed.

Same here, running on NFS/mail/web server & development workstation without
issues. I was really dismayed to see the IMHO unreasonably high coalescing
defaults.

> I've got no feedback at all to my original posting of this patch and questions
> 
> 	https://www.spinics.net/lists/netdev/msg457173.html
> 
> neither from Francois, nor from any people from Realtek during one month.

I thought I had already replied to your previous mail, but apparently had
not..sorry. :/

Tested-by: Holger Hoffstätte <holger@applied-asynchrony.com>

> So I suggest we simply apply it to net-next.git now.

cheers!

Holger
