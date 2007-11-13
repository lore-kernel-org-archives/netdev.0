From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] cleanup pernet operation without CONFIG_NET_NS
Date: Tue, 13 Nov 2007 03:24:07 -0800 (PST)
Message-ID: <20071113.032407.155828314.davem@davemloft.net>
References: <20071107120007.GA10169@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devel@openvz.org, containers@lists.osdl.org,
	netdev@vger.kernel.org, clg@fr.ibm.com, benjamin.thery@bull.net
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55947
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752656AbXKMLYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 06:24:08 -0500
In-Reply-To: <20071107120007.GA10169@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed, 7 Nov 2007 15:00:07 +0300

> If CONFIG_NET_NS is not set, the only namespace is possible.
> 
> This patch removes list of pernet_operations and cleanups code a bit.
> This list is not needed if there are no namespaces. We should just call
> ->init method.
> 
> Additionally, the ->exit will be called on module unloading only. This
> case is safe - the code is not discarded. For the in/kernel code, ->exit
> should never be called.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied.
