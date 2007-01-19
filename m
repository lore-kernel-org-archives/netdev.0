From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 0/12] L2 network namespace (v3)
Date: Fri, 19 Jan 2007 09:07:45 +0900 (JST)
Message-ID: <20070119.090745.39279848.yoshfuji@linux-ipv6.org>
References: <200701171851.14734.dim@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, alexey@sw.ru, saw@sw.ru, akpm@osdl.org,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:46278 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932769AbXASAGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jan 2007 19:06:42 -0500
To: dim@openvz.org
In-Reply-To: <200701171851.14734.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <200701171851.14734.dim@openvz.org> (at Wed, 17 Jan 2007 18:51:14 +0300), Dmitry Mishin <dim@openvz.org> says:

> ===================================
> L2 network namespaces
> 
> The most straightforward concept of network virtualization is complete
> separation of namespaces, covering device list, routing tables, netfilter
> tables, socket hashes, and everything else.
> 
> On input path, each packet is tagged with namespace right from the
> place where it appears from a device, and is processed by each layer
> in the context of this namespace.
> Non-root namespaces communicate with the outside world in two ways: by
> owning hardware devices, or receiving packets forwarded them by their parent
> namespace via pass-through device.

Can you handle multicast / broadcast and IPv6, which are very important?

--yoshfuji
