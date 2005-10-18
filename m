From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [BUG]NULL pointer dereference in ipv6_get_saddr()
Date: Wed, 19 Oct 2005 01:21:57 +0900 (JST)
Message-ID: <20051019.012157.11460212.yoshfuji@linux-ipv6.org>
References: <435512F5.1040502@21cn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750971AbVJRQWG@vger.kernel.org>
To: yanzheng@21cn.com
In-Reply-To: <435512F5.1040502@21cn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <435512F5.1040502@21cn.com> (at Tue, 18 Oct 2005 23:21:25 +0800), Yan Zheng <yanzheng@21cn.com> says:

> When I use command "ip -f inet6 route get fec0::1", kernel Oops occurs.
> I found it's due to ip_route_output return address of ip6_null_entry, ip6_null_entry.rt6i_idev is NULL.

I think this is already fixed in head.
I don't remember if we pushed this to stable...

--yoshfuji
