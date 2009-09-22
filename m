From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] net: fix CONFIG_NET=n build on sparc64
Date: Mon, 21 Sep 2009 22:38:03 -0700 (PDT)
Message-ID: <20090921.223803.75755454.davem@davemloft.net>
References: <200909181952.n8IJqEdD024614@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45747
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754832AbZIVFhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 01:37:45 -0400
In-Reply-To: <200909181952.n8IJqEdD024614@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 18 Sep 2009 12:52:13 -0700

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> sparc64 allnoconfig:
> 
> arch/sparc/kernel/built-in.o(.text+0x134e0): In function `sys32_recvfrom':
> : undefined reference to `compat_sys_recvfrom'
> arch/sparc/kernel/built-in.o(.text+0x134e4): In function `sys32_recvfrom':
> : undefined reference to `compat_sys_recvfrom'
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
