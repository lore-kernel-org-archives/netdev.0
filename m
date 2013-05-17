From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] filter: do not output bpf image address for
 security reason
Date: Fri, 17 May 2013 16:48:37 -0700
Message-ID: <1368834517.3301.130.camel@edumazet-glaptop>
References: <1368833499.3301.126.camel@edumazet-glaptop>
	 <1368834171.2194.98.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:34896 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755139Ab3EQXsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 19:48:39 -0400
Received: by mail-pb0-f44.google.com with SMTP id wz17so3745196pbc.31
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 16:48:39 -0700 (PDT)
In-Reply-To: <1368834171.2194.98.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-17 at 16:42 -0700, Joe Perches wrote:

> Are stable equivalents for versions before commit 79617801ea0
> necessary?
> 

I do not think so.

In order to get these messages printed, the admin had to specifically do

echo 2 >/proc/sys/net/core/bpf_jit_enable

And quite frankly I doubt anybody would need to do such thing, but
netdev guys writing/patching BPF JIT

And even with these messages printed, you need some bug in the kernel
allowing an exploit.
