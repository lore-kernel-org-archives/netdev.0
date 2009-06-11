From: David Miller <davem@davemloft.net>
Subject: Re: netfilter 00/31: netfilter update
Date: Thu, 11 Jun 2009 16:40:47 -0700 (PDT)
Message-ID: <20090611.164047.74924409.davem@davemloft.net>
References: <4A310C9E.3050904@trash.net>
	<4A311AB9.3060205@trash.net>
	<20090611.161910.109357779.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50918
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752457AbZFKXkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 19:40:45 -0400
In-Reply-To: <20090611.161910.109357779.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 11 Jun 2009 16:19:10 -0700 (PDT)

> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 11 Jun 2009 16:54:49 +0200
> 
>> I've now merged your latest tree and added the attached patch on top
>> to fix the compile error. This will unfortunately leave a small window
>> of commits that don't compile cleanly. If you prefer to have this
>> fixed
>> differently, please let me know, otherwise
>> 
>> Please pull from:
>> 
>> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git
>> master
> 
> Works for me, pulled, thanks!

Nevermind, still broken:

net/ipv4/netfilter/ip_tables.c: In function 'ipt_do_table':
net/ipv4/netfilter/ip_tables.c:421: error: 'comefrom' undeclared (first use in this function)
net/ipv4/netfilter/ip_tables.c:421: error: (Each undeclared identifier is reported only once
net/ipv4/netfilter/ip_tables.c:421: error: for each function it appears in.)

You're not testing what you're sending to me.

Again, un-pulled.
