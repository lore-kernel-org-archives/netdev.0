From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Allow Both IPv6 and IPv4 Sockets on the Same Port
Date: Fri, 04 Oct 2002 00:19:29 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021004.001929.03389091.yoshfuji@linux-ipv6.org>
References: <20021003.231534.83777766.yoshfuji@linux-ipv6.org>
	<20021004.000631.28088811.yoshfuji@linux-ipv6.org>
	<20021003.080408.78030688.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20021003.080408.78030688.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20021003.080408.78030688.davem@redhat.com> (at Thu, 03 Oct 2002 08:04:08 -0700 (PDT)), "David S. Miller" <davem@redhat.com> says:

>    I remember that test for daddr is for existing sockets, 
>    not for socket doing XXX_get_port().
>    So, I think I don't need to remove that.
> 
> Where can daddr/dport be non-zero during get_port()?

test for daddr if for sk2.
sk2 is iterator for existing sockets, which can be "connected."
daddr can be non-zero, can't it?
Am I wrong???

--yoshfuji
