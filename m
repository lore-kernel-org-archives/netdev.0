From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/2] cleanup pernet operation without CONFIG_NET_NS
Date: Thu, 15 Nov 2007 07:13:36 -0700
Message-ID: <m1bq9vy4tr.fsf@ebiederm.dsl.xmission.com>
References: <20071107120007.GA10169@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, containers@lists.osdl.org,
	netdev@vger.kernel.org, clg@fr.ibm.com, benjamin.thery@bull.net
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:36853 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbXKOOPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 09:15:39 -0500
In-Reply-To: <20071107120007.GA10169@iris.sw.ru> (Denis V. Lunev's message of
	"Wed, 7 Nov 2007 15:00:07 +0300")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Denis V. Lunev" <den@openvz.org> writes:

> If CONFIG_NET_NS is not set, the only namespace is possible.
>
> This patch removes list of pernet_operations and cleanups code a bit.
> This list is not needed if there are no namespaces. We should just call
> ->init method.
>
> Additionally, the ->exit will be called on module unloading only. This
> case is safe - the code is not discarded. For the in/kernel code, ->exit
> should never be called.

This patch looks sane, and reasonable in the !CONFIG_NET_NS case.

Eric
