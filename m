From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: IP-ID field of ICMP echo request
Date: Mon, 07 Jul 2003 22:11:19 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030707.221119.105548240.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.51.0307071420020.2129@dns.toxicfilms.tv>
	<20030707.213930.07095787.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.51.0307071443080.3379@dns.toxicfilms.tv>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, solt@dns.toxicfilms.tv
Return-path: <netdev-bounce@oss.sgi.com>
To: kohei@cysols.com
In-Reply-To: <Pine.LNX.4.51.0307071443080.3379@dns.toxicfilms.tv>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.51.0307071443080.3379@dns.toxicfilms.tv> (at Mon, 7 Jul 2003 14:48:41 +0200 (CEST)), Maciej Soltysiak <solt@dns.toxicfilms.tv> says:

> > No, he is not talking about ICMP Identifier (RFC792 Page 14),
> > but IP Identification (RFC791 Page 29).
> Aah, yes, I misread. Sorry.
> 
> Anyway I tested it on 2.4.2 and 2.4.18, 2.5.74 and 2.4.21, they set IP ID
> to 0. At first I thought it was that issue with early 2.4, but it seems it
> has been there for a while.

It seems linux-2.2.22 behaves similarly.

Well..., I remember the DF bit.
Kohei, add "-M dont" option (do not set DF flag) and 
we can see non-zero IPID, can't we?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
