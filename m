From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [RFC PATCH net-2.6.26 3/3] [NET] NETNS: Omit
 seq_net_private->net without CONFIG_NET_NS.
Date: Wed, 26 Mar 2008 02:09:44 +0900 (JST)
Message-ID: <20080326.020944.84725747.yoshfuji@linux-ipv6.org>
References: <20080325.231507.32154495.yoshfuji@linux-ipv6.org>
	<47E91EA0.20204@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:55004 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755439AbYCYRIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 13:08:18 -0400
In-Reply-To: <47E91EA0.20204@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <47E91EA0.20204@openvz.org> (at Tue, 25 Mar 2008 18:47:44 +0300), Pavel Emelyanov <xemul@openvz.org> says:

> YOSHIFUJI Hideaki / 吉藤英明 wrote:
> > Without CONFIG_NET_NS, no namespace other than &init_net exists,
> > no need to store net in seq_net_private.
> > 
> > Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Acked-by: Pavel Emelyanov <xemul@openvz.org>

Thanks.
Since I've found several issues by myself, I'll respin these patches.

--yoshfuji
