From: Stefano Brivio <sbrivio@redhat.com>
Subject: Re: WARN_ON() in __nf_hook_entries_try_shrink()
Date: Fri, 8 Sep 2017 02:11:24 +0200
Message-ID: <20170908021124.1f4f409e@elisabeth>
References: <CA+55aFw64ihu1bai0Em8pXD4dZ-wFVtV7BRjWbDLLb2MPWWXkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Aaron Conole <aconole@bytheb.org>, Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        David Miller <davem@davemloft.net>,
        NetFilter <netfilter-devel@vger.kernel.org>,
        coreteam@netfilter.org,
        Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40194 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750914AbdIHALc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 20:11:32 -0400
In-Reply-To: <CA+55aFw64ihu1bai0Em8pXD4dZ-wFVtV7BRjWbDLLb2MPWWXkw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 7 Sep 2017 17:01:12 -0700
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On shutdown I get this (edited down a bit to be more legible):
> 
>   Stopping firewalld - dynamic firewall daemon...
>   NETFILTER_CFG table=nat family=2 entries=55
>   NETFILTER_CFG table=mangle family=2 entries=40
>   NETFILTER_CFG table=raw family=2 entries=28
>   NETFILTER_CFG table=security family=2 entries=13
>   NETFILTER_CFG table=filter family=2 entries=93
>   ------------[ cut here ]------------
>   WARNING: CPU: 1 PID: 21512 at net/netfilter/core.c:218
> __nf_hook_entries_try_shrink+0x106/0x130

Should be fixed by:

	http://patchwork.ozlabs.org/patch/810570/
