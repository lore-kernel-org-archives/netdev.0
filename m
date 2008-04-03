From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: Three TCP/IP warnings in 2.6.25-rc7-git1
Date: Thu, 3 Apr 2008 08:56:07 +0300
Message-ID: <20080403055435.M45441@visp.net.lb>
References: <47F15200.3060706@linux.intel.com> <47F46945.40500@linux.intel.com> <20080402.222846.92587028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: David Miller <davem@davemloft.net>, arjan@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:34442 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757818AbYDCF4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 01:56:16 -0400
In-Reply-To: <20080402.222846.92587028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I can reproduce it during one day on my loaded proxies. I have:

[223178.376188] WARNING: at net/ipv4/tcp_input.c:2532 tcp_ack+0xd83/0x17bd()
and
[273139.505308] WARNING: at net/ipv4/tcp_input.c:2173
tcp_mark_head_lost+0x11e/0x126()

This two... maybe third, but i didn't notice it yet.

On Wed, 02 Apr 2008 22:28:46 -0700 (PDT), David Miller wrote
> From: Arjan van de Ven <arjan@linux.intel.com>
> Date: Wed, 02 Apr 2008 22:21:09 -0700
> 
> > It would be not so nice to ship a 2.6.25 that triggers these frequently,
> > it has the risk of causing many user bugreports to this list and other
> > places...
> 
> I wouldn't call it frequently, on at least an individual basis,
> because nobody we try to get feedback from can reproduce this
> reliably.  That's the only reason this isn't fixed yet, despite
> all of Ilpo's efforts.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

