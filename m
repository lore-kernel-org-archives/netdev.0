From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 06 May 2014 09:39:19 -0700
Message-ID: <1399394359.15399.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1399328773-6531-9-git-send-email-andi@firstfloor.org>
	 <20140505.231229.136734008603421707.davem@davemloft.net>
	 <20140506032114.GP2382@two.firstfloor.org>
	 <20140505.232327.578134514220748085.davem@davemloft.net>
	 <20140506155703.GA20391@cloud>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: josh@joshtriplett.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:50199 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbaEFQjW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 12:39:22 -0400
In-Reply-To: <20140506155703.GA20391@cloud>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-05-06 at 08:57 -0700, josh@joshtriplett.org wrote:

> A NAK isn't going to cut it, here; tiny Linux systems are going to
> exist, and they shouldn't have to maintain a long-term out-of-tree fork
> or use crazy things like LWIP.

What's wrong with user space implementations of networking stacks ?

For many usages, it can bring 10 times the performance of having user
application and kernel sockets.

In any cases, we do not model kernel implementations to 'compete' with
user space.

We simply can not compete with user space, as a programmer is free to
keep what he really wants/needs.

I have started using linux on 386/486 pcs which had more than 2MB of
memory, it makes me sad we want linux-3.16 to run on this kind of
hardware, and consuming time to save few KB here and here.
