From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH] ipv6: do not add link-local address if one already exists
Date: Mon, 11 Aug 2014 09:27:50 +0900
Message-ID: <53E80E06.3070704@miraclelinux.com>
References: <d630f87aa617098553c3a3361fcf50aa@mail.marples.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	"David S. Miller\"" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Roy Marples <roy@marples.name>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og105.obsmtp.com ([64.18.2.163]:47042 "HELO
	exprod7og105.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751407AbaHKA1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2014 20:27:55 -0400
Received: by mail-pd0-f175.google.com with SMTP id r10so9709778pdi.6
        for <netdev@vger.kernel.org>; Sun, 10 Aug 2014 17:27:55 -0700 (PDT)
In-Reply-To: <d630f87aa617098553c3a3361fcf50aa@mail.marples.name>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Roy Marples wrote:
> Hi
>
> Currently the kernel will always add an IPv6 link-local address
> based on the hardware address when the interface is brought up.
> This is probably based on the assumption that userland would
> never add one before the interface is brought up.
>
> However, one at least one userland application (dhcpcd) does this so
> it can implement RFC7217 which can be used for link-local addresses
> as well.
>
> Attached is a patch which checks to see if a link-local address exists
> before indiscriminately adding one.

Well, I think this is incomplete, for example, we will continue generating
global address from eui64.

I think we should implement such functionality through "if token" bits.

--yoshfuji
