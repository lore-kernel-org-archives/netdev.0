From: Peter Bieringer <pb@bieringer.de>
Subject: Re: (usagi-users 03187) Re: netfilter6: ICMPv6 type 143 doesn't
 match
Date: Sun, 09 Jan 2005 18:41:38 +0100
Message-ID: <097631C1DDA76BD36ECBEFFD@gate.muc.bieringer.de>
References: <6050E336B1A0D7D8E70C66F3@t1mobil.muc.aerasec.de>
 	<200412270417.iBR4HZRG021429@toshiba.co.jp>
 <20041227.100205.102356251.yoshfuji@linux-ipv6.org>
 <EA4274721EC980393BB13B5E@worker.muc.bieringer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yasuyuki.kozakai@toshiba.co.jp, netdev@oss.sgi.com, laforge@gnumonks.org,
        kaber@trash.net, netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: usagi-users@linux-ipv6.org
In-Reply-To: <EA4274721EC980393BB13B5E@worker.muc.bieringer.de>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



--On Saturday, January 08, 2005 12:45:14 PM +0100 Peter Bieringer
<pb@bieringer.de> wrote:

> 12:40:48.484375 fe80::****:**** > ff02::1: HBH (rtalert: 0x0000)
> (padn)[icmp6 sum ok] icmp6: multicast listener query max resp delay: 2000
> addr: :: [hlim 1] (len 36)
>         0x0000:  6000 0000 0024 0001 fe80 0000 0000 0000  `....$..........
>         0x0010:  0000 0000 **** **** ff02 0000 0000 0000  ................
>         0x0020:  0000 0000 0000 0001 3a00 0502 0000 0100  ........:.......
>         0x0030:  8200 a03a 07d0 0000 0000 0000 0000 0000  ...:............
>         0x0040:  0000 0000 0000 0000 027d 0000            .........}..

> 12:42:42.046741 fe80::200:**ff:fe**:**** > ff02::16: HBH (rtalert: 0x0000)
> (padn)[icmp6 sum ok] icmp6: type-#143 [hlim 1] (len 56)
>         0x0000:  6000 0000 0038 0001 fe80 0000 0000 0000  `....8..........
>         0x0010:  0200 **ff fe** **** ff02 0000 0000 0000  .....*..........
>         0x0020:  0000 0000 0000 0016 3a00 0502 0000 0100  ........:.......
>         0x0030:  8f00 a1d9 0000 0002 0300 0000 ff02 0000  ................
>         0x0040:  0000 0000 0000 0000 0001 0002 0300 0000  ................
>         0x0050:  ff05 0000 0000 0000 0000 0000 0001 0003  ................

> I would be glad, if someone can more dig into and provide me patches for
> kernel and probably also for tcpdump.

I mentioned "tcpdump" here also because I played with tcpdump filters
around and found that while tcpdump displays "icmp6" packet, the filter
"icmp6" won't work at all, only the "ip6" filter matches.

Understandable, because the next protocol is "00" (hop-by-hop), but I don't
know whether this is well enough. My opinion is that tcpdump should be
improved to be more smarter (if possible).

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
