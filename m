From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@wide.ad.jp>
Subject: Re: Neighbor cache behavior
Date: Fri, 10 May 2002 08:35:58 +0900
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020510083558C.yoshfuji@wide.ad.jp>
References: <20020503095402W.yoshfuji@wide.ad.jp>
	<000201c1f7ae$2c5c2110$4f6015ac@VAIO>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: xiaoning@docomolabs-usa.com
In-Reply-To: <000201c1f7ae$2c5c2110$4f6015ac@VAIO>
List-Id: netdev.vger.kernel.org

In article <000201c1f7ae$2c5c2110$4f6015ac@VAIO> (at Thu, 9 May 2002 16:06:37 -0700), "Xiaoning He" <xiaoning@docomolabs-usa.com> says:

> If so, I have looked into the Linux kernel, however, I don't know where
> in the Linux kernel the code will check the Neighbor. I tried to search
> the function ndisc_send_ns() because I think that's the function who
> will handle the sending the NS is there is no entry in the NC. However,
> it doesn't help. 

skb->dst->output() is the entry to resolve neighbor when sending
packets.


> Also, I think I really need to know the Linux Kernel so that I don't
> need always ask this kind of question. Is there any good book and
> tutorial available which can give me a overall picture about how to
> program the networking program for both user-land and kernel in the
> Linux?

keep reading source codes.:-)

--yoshfuji
