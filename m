From: Patrick McHardy <kaber@trash.net>
Subject: Re: tc related lockdep warning.
Date: Wed, 27 Sep 2006 12:14:06 +0200
Message-ID: <451A4EEE.6080004@trash.net>
References: <20060925124352.GA1592@ff.dom.local> <1159188473.5301.68.camel@jzny2> <4517D9A6.70307@trash.net> <45195219.7050105@trash.net> <20060926212034.GA3134@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Jarek Poplawski <jarkao2@o2.pl>,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34999 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S965510AbWI0KOI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 06:14:08 -0400
To: Dave Jones <davej@redhat.com>
In-Reply-To: <20060926212034.GA3134@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Jones wrote:
> With this patch, I get no lockdep warnings, but the machine locks up completely.
> I hooked up a serial console, and found this..
> 
> 
> u32 classifier
>     Performance counters on
>     input device check on 
>     Actions configured 
> BUG: warning at net/sched/sch_htb.c:395/htb_safe_rb_erase()

I can't reproduce this, could you send me your tc script please?
Did you do anything to trigger this?
