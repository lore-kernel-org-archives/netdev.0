From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: IPv6/sparc64: icmp port unreachable corruption
Date: Tue, 11 Nov 2003 01:06:53 -0600 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111.010653.76483304.yoshfuji@linux-ipv6.org>
References: <20031109122844.GA14241@wsx.ksp.sk>
	<20031110214603.0057e365.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jan.oravec@6com.sk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20031110214603.0057e365.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20031110214603.0057e365.davem@redhat.com> (at Mon, 10 Nov 2003 21:46:03 -0800), "David S. Miller" <davem@redhat.com> says:

> > 13:17:47.191547 3ffe:80ee:3bd:0:a00:20ff:fec7:a192 > 3ffe:80ee:a:0:201:3ff:fed5:bd1e: [|icmp6] (len 72, hlim 62)
> > 0x0000   6000 0000 0048 3a3e 3ffe 80ee 03bd 0000        ....H:>?.......
> > 0x0010   0a00 20ff fec7 a192 3ffe 80ee 000a 0000        ........?.......
> > 0x0020   0201 03ff fed5 bd1e 0104 aa7c 0000 0000        ...........|....
> > 0x0030   0000 0064 0000 0000 0100 0000 0100 0000        ...d............
> > 0x0040   aaaa aaaa aaaa aaaa 9680 c00b c622 7fec        ............."..
> > 0x0050   aaaa aaaa aaaa aaaa 9680 c00b c622 7ffc        ............."..
> > 0x0060   aaaa aaaa 0000 0000 8a10 2000 04c2 8049        ...............I
> 
> What specifically about this packet makes you think it is corrupted?
:
> So why does tcpdump not say that this is "udp port XXX unreachable"
> like it does for the x86 generated packet.
> 
> Incorrect checksum or corrupted payload after the icmp6 header?

0x0030- should be the copy of the original packet.
it is corrupted.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
