From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: Splice on blocking TCP sockets again..
Date: Tue, 29 Sep 2009 23:40:31 -0600
Message-ID: <20090930054031.GY22310@obsidianresearch.com>
References: <20090930004820.GC19540@obsidianresearch.com> <4AC2E481.5060509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Volker Lendecke <vl@samba.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 139-142-54-143.atc.vaillant.ca ([139.142.54.143]:38183 "EHLO
	quartz.edm.orcorp.ca" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752764AbZI3Fk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 01:40:28 -0400
Content-Disposition: inline
In-Reply-To: <4AC2E481.5060509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> One way to handle this is to switch tcp_read() to use the underlying file O_NONBLOCK
> flag, as other socket operations do. And let SPLICE_F_NONBLOCK control the pipe output only.

Thanks Eric, this seems reasonable from my userspace perspective.

I admit I don't understand why SPLICE_F_NONBLOCK exists, it seems very
un-unixy to have a syscall completely ignore the NONBLOCK flag of the
fd it is called on. Ie setting NONBLOCK on the pipe itself does
nothing when using splice..

Jason
