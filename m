From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: tcp: Fix a PTO timing granularity issue
Date: Wed, 27 May 2015 10:24:16 -0700
Message-ID: <1432747456.4060.409.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432663992.4060.286.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432671437-19140-1-git-send-email-ido@wizery.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB40A1A@AcuExch.aculab.com>
	 <1432734077.4060.382.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150527144029.GA558@WorkStation.home>
	 <1432738585.4060.392.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150527152337.GB558@WorkStation.home>
	 <1432743816.4060.404.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150527165403.GC558@WorkStation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Nandita Dukkipati <nanditad@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ido Yariv <idox.yariv@intel.com>
To: Ido Yariv <ido@wizery.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:36353 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbbE0RYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 13:24:18 -0400
In-Reply-To: <20150527165403.GC558@WorkStation.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-27 at 12:54 -0400, Ido Yariv wrote:
> Hi Eric,

> That's a nice optimization ;)
> 
> However, I think that with Nicholas Mc Guire's recent changes to
> msecs_to_jiffies (http://marc.info/?l=linux-kernel&m=143195210010666),
> we should get this for free, no?

Well, on net and net-next tree we currently have :

$ grep msecs_to_jiffies include/linux/jiffies.h
extern unsigned long msecs_to_jiffies(const unsigned int m);

Given your patch is for stable, I would not mind having this done
anyway.
