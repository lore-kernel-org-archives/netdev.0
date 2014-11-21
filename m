From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] bonding: clear header_ops when last slave detached (v2)
Date: Fri, 21 Nov 2014 10:17:12 -0800
Message-ID: <CAHA+R7Pnn4TxRQcR4KBRrZV8mqsm-YznMMvXVasji07caY9b1g@mail.gmail.com>
References: <1416374292-10993-1-git-send-email-wen.gang.wang@oracle.com>
	<1416375565.14060.43.camel@edumazet-glaptop2.roam.corp.google.com>
	<546C4022.5010509@oracle.com>
	<CAHA+R7OyA_V149bpE8qUgG9epU-5UG8cf=zOgh5ZXVB3ZFZHUw@mail.gmail.com>
	<1416465685.8629.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7PKRbBNwfUWRAsVHQreKsGXBc8CHorZRuyCfvwL4O=y+g@mail.gmail.com>
	<1416516104.8629.39.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7Me4zPdGpeQVHFLLGVq=4cVar09jQFyjA81nxF_Fmuppw@mail.gmail.com>
	<1416521035.8629.49.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7P9XhGQZXFy6frxOyZJ4rX_MdVgY3kAPE1_wDNcvYd_yA@mail.gmail.com>
	<23563.1416523985@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Wengang <wen.gang.wang@oracle.com>,
	netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:59976 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbaKUSRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 13:17:13 -0500
Received: by mail-qc0-f173.google.com with SMTP id i17so4159699qcy.32
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 10:17:12 -0800 (PST)
In-Reply-To: <23563.1416523985@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2014 at 2:53 PM, Jay Vosburgh
<jay.vosburgh@canonical.com> wrote:
> Cong Wang <cwang@twopensource.com> wrote:
>
>>Also, no one seems to care about my previous question:
>>why only bonding has the problem?
>
>         Bonding has the problem because it stashes a pointer to a data
> structure (the header_ops) from another module, and when that module is
> unloaded the dangling pointer may be dereferenced if it's not either
> cleared or made to never go away.

I knew, please re-read my question, I was asking why ONLY bonding
has the problem, i.e. why not neigh or whatever else calling
header_ops->foo()? :)

As I said, I may miss some try_get_module() somewhere of course.
Needs more digging.
