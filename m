From: kuznet@ms2.inr.ac.ru
Subject: Re: RFC2292(bis) checksum support
Date: Mon, 20 May 2002 07:51:37 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200205200351.HAA01589@sex.inr.ac.ru>
References: <20020520120406A.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <owner-netdev@oss.sgi.com>
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=)
In-Reply-To: <20020520120406A.yoshfuji@linux-ipv6.org> from "YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" at May 20, 2 12:04:06 pm
List-Id: netdev.vger.kernel.org

Hello!

> Checksum for ICMPv6 is mandatory like ones for TCP and UDP (for IPv6) are.
> We should not (be able to) disable checksum for TCP, UDP AND ICMPv6,
> should we?

It is mandatory on _network level_, not on api level.
F.e. checksum is mandatory for ICMPv4 too, however, we used to calculate it
in user space and nobody cries about this.

Do you see what is the mistake in the rfc? Authors did a wrong sillogism
and had to write several paragraphs of meaningless text to explain the mess.

Shortly, you may consider this as a compatible extension of standard API.
(which costs deleting several lines of code. :-))


> yes.  I just forgot to delete that original line while making this patch;
> sorry.

OK.

Alexey
