From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] uapi: fix compatability of linux/in.h with
 netinet/in.h
Date: Sat, 27 Jun 2015 16:20:41 -0700 (PDT)
Message-ID: <20150627.162041.2168402415351061903.davem@davemloft.net>
References: <20150625231206.4a9c3daf@uryu.home.lan>
	<20150627.145248.343550575965644423.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60948 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029AbbF0XUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jun 2015 19:20:45 -0400
In-Reply-To: <20150627.145248.343550575965644423.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sat, 27 Jun 2015 14:52:48 -0700 (PDT)

> Applied.

Reverted, as it breaks the build.

Please test your patches.

In file included from include/linux/in.h:23:0,
                 from include/uapi/linux/netfilter.h:7,
                 from include/linux/netfilter_defs.h:4,
                 from include/net/netns/netfilter.h:4,
                 from include/net/net_namespace.h:22,
                 from include/linux/init_task.h:15,
                 from kernel/fork.c:562:
include/uapi/linux/in.h:25:5: warning: "__UAPI_DEF_IN_IPPROTO" is not defined [-Wundef]
 #if __UAPI_DEF_IN_IPPROTO
     ^
include/uapi/linux/in.h:82:5: warning: "__UAPI_DEF_IN_ADDR" is not defined [-Wundef]
 #if __UAPI_DEF_IN_ADDR
     ^
include/uapi/linux/in.h:165:5: warning: "__UAPI_DEF_IP_MREQ" is not defined [-Wundef]
 #if __UAPI_DEF_IP_MREQ
     ^
include/uapi/linux/in.h:219:5: warning: "__UAPI_DEF_IN_PKTINFO" is not defined [-Wundef]
 #if __UAPI_DEF_IN_PKTINFO
     ^
include/uapi/linux/in.h:228:6: warning: "__UAPI_DEF_SOCKADDR_IN" is not defined [-Wundef]
 #if  __UAPI_DEF_SOCKADDR_IN
      ^
include/uapi/linux/in.h:242:5: warning: "__UAPI_DEF_IN_CLASS" is not defined [-Wundef]
 #if __UAPI_DEF_IN_CLASS
     ^
