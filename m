From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] doc: fix the compile fix of txtimestamp.c
Date: Sun, 11 Jan 2015 21:56:14 -0500 (EST)
Message-ID: <20150111.215614.2186929329384615040.davem@davemloft.net>
References: <1420909698-25025-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	vlee@twopensource.com, carlos@redhat.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbbALC4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2015 21:56:16 -0500
In-Reply-To: <1420909698-25025-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Sat, 10 Jan 2015 12:08:18 -0500

> From: Willem de Bruijn <willemb@google.com>
> 
> A fix to ipv6 structure definitions removed the now superfluous
> definition of in6_pktinfo in this file.
> 
> But, use of the glibc definition requires defining _GNU_SOURCE
> (see also https://sourceware.org/bugzilla/show_bug.cgi?id=6775).
> 
> Before this change, the following would fail for me:
> 
>   make
>   make headers_install
>   make M=Documentation/networking/timestamping
> 
> with
> 
>   Documentation/networking/timestamping/txtimestamp.c: In function '__recv_errmsg_cmsg':
>   Documentation/networking/timestamping/txtimestamp.c:205:33: error: dereferencing pointer to incomplete type
>   Documentation/networking/timestamping/txtimestamp.c:206:23: error: dereferencing pointer to incomplete type
> 
> After this patch compilation succeeded.
> 
> Fixes: cd91cc5bdddf ("doc: fix the compile error of txtimestamp.c")
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks.
