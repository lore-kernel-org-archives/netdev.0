From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: IPv6 extension header privileges
Date: Fri, 27 May 2016 12:37:47 +0900
Message-ID: <5747C10B.1000006@miraclelinux.com>
References: <CALx6S36x2+HBLSYVBi0+rQAgejbVvvFF7fr0P13cTspxpJQCLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com
To: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35846 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932168AbcE0Dhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 23:37:52 -0400
Received: by mail-pa0-f45.google.com with SMTP id eu11so26620104pad.3
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 20:37:51 -0700 (PDT)
In-Reply-To: <CALx6S36x2+HBLSYVBi0+rQAgejbVvvFF7fr0P13cTspxpJQCLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Tom Herbert wrote:
> Hi,
> 
> In ipv6_sockglue.c I noticed:
> 
> /* hop-by-hop / destination options are privileged option */
> retv = -EPERM;
> if (optname != IPV6_RTHDR && !ns_capable(net->user_ns, CAP_NET_RAW))
>            break;
> 
> Can anyone provide that rationale as to why these are privileged ops?

It is better to disallow by default for security.
FreeBSD does this in the same way.
We may have sysctl bitmaps, of course.

--yoshfuji

> 
> Thanks,
> Tom
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
