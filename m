From: Andrew Morton <akpm@osdl.org>
Subject: Re: [take13 1/3] kevent: Core files.
Date: Thu, 24 Aug 2006 23:20:24 -0700
Message-ID: <20060824232024.0d230823.akpm@osdl.org>
References: <11563322941645@2ka.mipt.ru>
	<11563322971212@2ka.mipt.ru>
	<20060824200322.GA19533@infradead.org>
	<20060825054815.GC16504@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:52892 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964810AbWHYGVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 02:21:10 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060825054815.GC16504@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 25 Aug 2006 09:48:15 +0400
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> kmalloc is really slow actually - it always shows somewhere on top 
> in profiles and brings noticeble overhead

It shouldn't.  Please describe the workload and send the profiles.
