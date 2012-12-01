From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next:master 100/106] net/ipv4/inet_hashtables.c:242:21:
 sparse: restricted __portpair degrades to integer
Date: Sat, 01 Dec 2012 10:46:12 -0800
Message-ID: <1354387572.20109.524.camel@edumazet-glaptop>
References: <50ba4a7c.o5mv0SK27e0dxcwD%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:49449 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029Ab2LASqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 13:46:16 -0500
Received: by mail-vc0-f174.google.com with SMTP id d16so679888vcd.19
        for <netdev@vger.kernel.org>; Sat, 01 Dec 2012 10:46:16 -0800 (PST)
In-Reply-To: <50ba4a7c.o5mv0SK27e0dxcwD%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-12-02 at 02:20 +0800, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   577b981714b0b3530817569bf705bd74881efc83
> commit: ce43b03e8889475817d427b1f3724c7e294b76eb [100/106] net: move inet_dport/inet_num in sock_common
> 
> 
> sparse warnings:
> 
> + net/ipv4/inet_hashtables.c:242:21: sparse: restricted __portpair degrades to integer
> net/ipv4/inet_hashtables.c:246:29: sparse: restricted __portpair degrades to integer
> net/ipv4/inet_hashtables.c:267:21: sparse: restricted __portpair degrades to integer
> net/ipv4/inet_hashtables.c:274:29: sparse: restricted __portpair degrades to integer
> net/ipv4/inet_hashtables.c:326:21: sparse: restricted __portpair degrades to integer
> net/ipv4/inet_hashtables.c:341:21: sparse: restricted __portpair degrades to integer
> --
> + net/ipv6/inet6_hashtables.c:92:21: sparse: restricted __portpair degrades to integer
> net/ipv6/inet6_hashtables.c:95:29: sparse: restricted __portpair degrades to integer
> net/ipv6/inet6_hashtables.c:111:21: sparse: restricted __portpair degrades to integer
> net/ipv6/inet6_hashtables.c:117:29: sparse: restricted __portpair degrades to integer
> net/ipv6/inet6_hashtables.c:248:21: sparse: restricted __portpair degrades to integer
> net/ipv6/inet6_hashtables.c:263:21: sparse: restricted __portpair degrades to integer
> 
> vim +242 net/ipv4/inet_hashtables.c

I'll send a fix, thanks for the report.
