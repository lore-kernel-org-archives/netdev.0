From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][IPSEC][0/6] fix conflict of device tunnels with the
 ipsec tunnel
Date: Thu, 08 Feb 2007 17:15:26 +0900 (JST)
Message-ID: <20070208.171526.01252631.yoshfuji@linux-ipv6.org>
References: <20070208170324.3e3a4d59.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@davemloft.net, miika@iki.fi,
	Diego.Beltrami@hiit.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org
To: kazunori@miyazawa.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54201 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161546AbXBHIOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 03:14:03 -0500
In-Reply-To: <20070208170324.3e3a4d59.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070208170324.3e3a4d59.kazunori@miyazawa.org> (at Thu, 8 Feb 2007 17:03:24 +0900), Kazunori MIYAZAWA <kazunori@miyazawa.org> says:

> We need this to use ipcomp with inter address family tunnel.
> 
> [1/6] extending xfrm4_tunnel utility to support inter address family for "sit"
> [2/6] extending xfrm6_tunnel utility to support inter address family
> [3/6] fix to refer encap_family when comparing the kernel generated xfrm_state
> [4/6] changing "ipip tunnel" and xfrm4_tunnel to the API
> [5/6] changing "ip6_tunnel" and xfrm6_tunnel to the API
> [6/6] make "sit tunnel" use xfrm4_tunnel_register 

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
