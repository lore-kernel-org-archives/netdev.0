From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [1/1] Kevent subsystem.
Date: Fri, 23 Jun 2006 15:18:50 +0900 (JST)
Message-ID: <20060623.151850.66747907.yoshfuji@linux-ipv6.org>
References: <20060622171436.GA26161@2ka.mipt.ru>
	<20060623.151244.02594148.yoshfuji@linux-ipv6.org>
	<20060622.231407.59469243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:37128 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932849AbWFWGR5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 02:17:57 -0400
To: davem@davemloft.net
In-Reply-To: <20060622.231407.59469243.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060622.231407.59469243.davem@davemloft.net> (at Thu, 22 Jun 2006 23:14:07 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Fri, 23 Jun 2006 15:12:44 +0900 (JST)
> 
> > We do not waste syscall entries; we can probably use socketcall
> > for sys_aio_recv, sys_aio_send (and maybe, sys_aio_sendfile).
> 
> socketcall is deprecated and some architectures do not even
> have a slot for it in their system call tables, one example
> is x86_64

Ah, okay.  Thanks.

--yoshfuji
