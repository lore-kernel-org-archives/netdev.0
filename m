From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: ipv6 UDP MSG_MORE oops fix
Date: Sun, 26 Oct 2003 18:50:23 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031026.185023.108406592.yoshfuji@linux-ipv6.org>
References: <20030807223421.70497d61.davem@redhat.com>
	<20030808.170839.90822982.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org,
        miyazawa@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030808.170839.90822982.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

This thread would be too old but anyway...

In article <20030808.170839.90822982.yoshfuji@linux-ipv6.org> (at Fri, 08 Aug 2003 17:08:39 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <20030807223421.70497d61.davem@redhat.com> (at Thu, 7 Aug 2003 22:34:21 -0700), "David S. Miller" <davem@redhat.com> says:
> 
> > Yoshfuji-san, I found the MSG_MORE udp bug.
> 
> Yes, thanks. This is what I told you before.
> I'm going to test if problems go away with this patch.

This fixes oops, but there remains several issues.
I'm about to send 3 patches to fix them.

[1/3] IPv6: Odd IPv6 header in UDPv6 packets when sending MSG_MORE flag
[2/3] NET: store cork'ing flow information in common storage in inet_opt
[3/3] IPv6: breakage of sendmsg to IPv4-mapped address via UDPv6 socket

Thanks in advance.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
