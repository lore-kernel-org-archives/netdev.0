From: David Miller <davem@davemloft.net>
Subject: Re: Kevent POSIX timers support.
Date: Mon, 11 Dec 2006 17:36:44 -0800 (PST)
Message-ID: <20061211.173644.130208821.davem@davemloft.net>
References: <20061128091602.GC15083@2ka.mipt.ru>
	<20061128.111300.105813754.davem@davemloft.net>
	<20061128192236.GA2051@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drepper@redhat.com, akpm@osdl.org, netdev@vger.kernel.org,
	zach.brown@oracle.com, hch@infradead.org,
	chase.venters@clientec.com, johann.borck@densedata.com,
	linux-kernel@vger.kernel.org, jeff@garzik.org, aviro@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35984
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750836AbWLLBgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 20:36:45 -0500
To: johnpol@2ka.mipt.ru
In-Reply-To: <20061128192236.GA2051@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Tue, 28 Nov 2006 22:22:36 +0300

> And, btw, last time I checked, aligned_u64 was not exported to
> userspace.

It is in linux/types.h and not protected by __KERNEL__ ifdefs.
Perhaps you mean something else?
