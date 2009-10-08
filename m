From: Thomas Chou <thomas@wytron.com.tw>
Subject: Re: [PATCH] net: Add netdev_alloc_skb_ip_align() helper
Date: Thu, 08 Oct 2009 12:36:57 +0800
Message-ID: <4ACD6C69.7040206@wytron.com.tw>
References: <1254969161-3609-1-git-send-email-thomas@wytron.com.tw> <4ACD585B.5080106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, thierry.reding@avionic-design.de,
	Nios2 development list <nios2-dev@sopc.et.ntust.edu.tw>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr25.hinet.net ([168.95.4.125]:46942 "EHLO msr25.hinet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751764AbZJHEgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2009 00:36:45 -0400
In-Reply-To: <4ACD585B.5080106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/08/2009 11:11 AM, Eric Dumazet wrote:
> Thomas Chou a =E9crit :
> You should do :
>
> size -=3D 4; /* strip the CRC */
> skb =3D netdev_alloc_skb(dev, size + NET_IP_ALIGN);
> if (skb) {
> 	skb_reserve(skb, NET_IP_ALIGN);
> 	...
> }
>
>
> Please check other implementations...
>
> David, maybe we should add following helper :
>
> [PATCH] net: Add netdev_alloc_skb_ip_align() helper

Hi Eric,

Thanks for the suggestion. I will follow your commit and send revised p=
atch.

- Thomas
