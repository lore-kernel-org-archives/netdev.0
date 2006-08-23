From: David Miller <davem@davemloft.net>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Wed, 23 Aug 2006 00:35:16 -0700 (PDT)
Message-ID: <20060823.003516.30182824.davem@davemloft.net>
References: <b3f268590608221743o493080d0t41349bc4336bdd0b@mail.gmail.com>
	<20060823065659.GC24787@2ka.mipt.ru>
	<20060823000758.5ebed7dd.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, sundell.software@gmail.com,
	kuznet@ms2.inr.ac.ru, nmiell@comcast.net,
	linux-kernel@vger.kernel.org, drepper@redhat.com,
	netdev@vger.kernel.org, zach.brown@oracle.com, hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2179
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751444AbWHWHfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 03:35:17 -0400
To: akpm@osdl.org
In-Reply-To: <20060823000758.5ebed7dd.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Wed, 23 Aug 2006 00:07:58 -0700

> I wonder whether designing-in a millisecond granularity is the right thing
> to do.  If in a few years the kernel is running tickless with high-res clock
> interrupt sources, that might look a bit lumpy.
> 
> Switching it to a __u64 nanosecond counter would be basically free on
> 64-bit machines, and not very expensive on 32-bit, no?

If it ends up in a structure we'll need to use the "aligned_u64" type
in order to avoid problems with 32-bit x86 binaries running on 64-bit
kernels.
