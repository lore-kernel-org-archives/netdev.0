From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Badness in dst_release (continuing saga)
Date: Thu, 30 Dec 2004 02:39:39 +0900 (JST)
Message-ID: <20041230.023939.88211501.yoshfuji@linux-ipv6.org>
References: <41CFDE1D.6000802@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, acme@conectiva.com.br, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <41CFDE1D.6000802@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <41CFDE1D.6000802@pobox.com> (at Mon, 27 Dec 2004 05:04:13 -0500), Jeff Garzik <jgarzik@pobox.com> says:

> Ok, it's happened again.  x86 SMP, 2.6.10-rc3-bk9.
> 
> I have left the machine up without rebooting, those with accounts may 
> ssh in.  First message occurs on Dec 24 in /var/log/messages.1, and they 
> continue in /var/log/messages and dmesg.  ssh to gw.yyz.us.
:
> Badness in dst_release at include/net/dst.h:149
>   [<f8c1124d>] ip6_dst_check+0x64/0x6a [ipv6]
>   [<f8c080da>] ip6_dst_lookup+0x1a7/0x1c1 [ipv6]
>   [<f8c1a4da>] udpv6_sendmsg+0x297/0x931 [ipv6]

Ok, thanks.

Due to badness of timing (I was almost offline for last a few days),
I could not login that machine before you rebooted.
However, I must have got some hints from information I was collecting.

I will look into the code (and come up with some debugging code at least).
Thank you again.

--yoshfuji
