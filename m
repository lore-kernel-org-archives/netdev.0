From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCHSET] Mobile IPv6 for 2.5.43
Date: Fri, 18 Oct 2002 02:18:02 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021018.021802.87011078.yoshfuji@linux-ipv6.org>
References: <20021017162624.GC16370@morphine.tml.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org, pekkas@netcore.fi, torvalds@transmeta.com,
   jagana@us.ibm.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: ajtuomin@morphine.tml.hut.fi
In-Reply-To: <20021017162624.GC16370@morphine.tml.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20021017162624.GC16370@morphine.tml.hut.fi> (at Thu, 17 Oct 2002 19:26:25 +0300), Antti Tuominen <ajtuomin@morphine.tml.hut.fi> says:

> The patch has been split for easier reading as follows:
> 
> ipv6_tunnel.patch	6over6 tunneling
> network_mods.patch	Modifications to network code and hooks

Several comments.

[ipv6_tunnel]

I think this is almost ok.

  1. I believe s/ARPHRD_IPV6_IPV6_TUNNEL/ARPHRD_TUNNEL6/.
  2. Please put outer address to hardware address in dev.
     Note: you need to modify SIOxxx ioctls too not to overrun!

[network_mods etc.]

  1. Too many hooks,
     and many duplicate codes in ipv6 stack and mipv6 stack.
     (prefix handler, header parser, ndisc handler etc...)

more comment will come later...


> http://www.mipl.mediapoli.com/patches/mipv6_cn_support.patch
> http://www.mipl.mediapoli.com/patches/mipv6_mn_support.patch
> http://www.mipl.mediapoli.com/patches/mipv6_ha_support.patch

Well, I can't find them. I hope they'll be available when I wake up
tomorrow...

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
