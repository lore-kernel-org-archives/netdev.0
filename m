From: David Miller <davem@davemloft.net>
Subject: Re: Crash in ip_conntrack on shutdown
Date: Wed, 01 Nov 2006 17:49:31 -0800 (PST)
Message-ID: <20061101.174931.66061218.davem@davemloft.net>
References: <45494243.20001@dslnorthwest.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:43964
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1752463AbWKBBtZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Nov 2006 20:49:25 -0500
To: shemminger@dslnorthwest.net
In-Reply-To: <45494243.20001@dslnorthwest.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@dslnorthwest.net>
Date: Wed, 01 Nov 2006 16:56:35 -0800

> My desktop machine (Fedora Core 6) crashed on during shutdown when 
> running latest
> 2.6.19-rc4 kernel. Machine is UP Amd64.
> 
> It looks like a null dereference in ip_conntrack. See screenshot.
>   
> http://picasaweb.google.com/stephen.hemminger/LinuxCrashes/photo#4992593950061821970

Can some x86_64 expert decode this?  I'm trying to figure out what
object is being NULL defer'd, and after taking a quick look at
this dump I can't figure it out.

I suspect there may also be a OOPS right before this one, I also
wonder if this was actually a BUG_ON() trigger.
