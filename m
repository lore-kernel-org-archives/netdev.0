From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] fix select() for SOCK_RAW sockets
Date: Wed, 08 Dec 2004 02:35:30 +0900 (JST)
Message-ID: <20041208.023530.26430801.yoshfuji@linux-ipv6.org>
References: <20041207045302.GA23746@linuxace.com>
	<20041207054840.GD61527@gaz.sfgoth.com>
	<20041207150834.GA75700@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel@linuxace.com, davem@davemloft.net, shemminger@osdl.org,
	linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <linux-net-owner@vger.kernel.org>
To: mitch@sfgoth.com
In-Reply-To: <20041207150834.GA75700@gaz.sfgoth.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20041207150834.GA75700@gaz.sfgoth.com> (at Tue, 7 Dec 2004 07:08:34 -0800), Mitchell Blank Jr <mitch@sfgoth.com> says:

> Phil: Here's a real patch for you to test.  I actually left inet_dgram_ops
> alone since it's an exported symbol (two of the users just want the .do_ioctl
> value which is the same between SOCK_DGRAM and SOCK_RAW; the other is ipv6
> where it's clearly dealing with a UDP socket -- therefore I think its safest
> to leave inet_dgram_ops to have the UDP behavior)

Probably, we need to do the same for ipv6, don't we?

--yoshfuji
