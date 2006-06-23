From: David Miller <davem@davemloft.net>
Subject: Re: [1/1] Kevent subsystem.
Date: Thu, 22 Jun 2006 23:14:07 -0700 (PDT)
Message-ID: <20060622.231407.59469243.davem@davemloft.net>
References: <20060622171436.GA26161@2ka.mipt.ru>
	<20060623.151244.02594148.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:23462
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932815AbWFWGOx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 02:14:53 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060623.151244.02594148.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Fri, 23 Jun 2006 15:12:44 +0900 (JST)

> We do not waste syscall entries; we can probably use socketcall
> for sys_aio_recv, sys_aio_send (and maybe, sys_aio_sendfile).

socketcall is deprecated and some architectures do not even
have a slot for it in their system call tables, one example
is x86_64
