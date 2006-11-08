From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take23 0/5] kevent: Generic event handling mechanism.
Date: Wed, 8 Nov 2006 11:21:48 +0300
Message-ID: <20061108082147.GA2447@2ka.mipt.ru>
References: <1154985aa0591036@2ka.mipt.ru> <11629182482886@2ka.mipt.ru> <20061107141718.f7414b31.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:52133 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1754426AbWKHIXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 03:23:04 -0500
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061107141718.f7414b31.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 07, 2006 at 02:17:18PM -0800, Andrew Morton (akpm@osdl.org) wrote:
> From: Andrew Morton <akpm@osdl.org>
> 
> If kevent_user_wait() gets -EFAULT on the attempt to copy the first event, it
> will return 0, which is indistinguishable from "no events pending".
> 
> It can and should return EFAULT in this case.

Correct, I missed that.
Thanks Andrew, I will put into my tree, -mm seems to have it already.

-- 
	Evgeniy Polyakov
