From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 3/5] sock_diag: allow to dump bpf filters
Date: Wed, 24 Apr 2013 09:22:45 -0700
Message-ID: <1366820565.8964.78.camel@edumazet-glaptop>
References: <51779426.7020800@6wind.com>
	 <1366818756-4234-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1366818756-4234-4-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:35046 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755689Ab3DXQWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 12:22:48 -0400
Received: by mail-pd0-f176.google.com with SMTP id r11so1229204pdi.7
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 09:22:47 -0700 (PDT)
In-Reply-To: <1366818756-4234-4-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-24 at 17:52 +0200, Nicolas Dichtel wrote:
> This patch allows to dump BPF filters attached to a socket with
> SO_ATTACH_FILTER. In other words, users allowing to open netlink sockets can
> see filters set on a socket (when the diag module of the socket family is
> loaded).

To my knowledge, opening netlink sockets is not restricted.

I do not want user lambda being able to see my BPF filters.

I am root, and was assuming user lambda could not spy on me.

$ cat /proc/net/packet 
sk       RefCnt Type Proto  Iface R Rmem   User   Inode
0000000000000000 3      10   0003   3     1 0      0      1089989
0000000000000000 3      10   0003   2     1 0      0      1050535
0000000000000000 3      2    888e   3     1 0      0      1041970


With this information, it seems safe enough, but the whole BPF could
give interesting ideas to user lambda.
