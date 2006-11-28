From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Kevent POSIX timers support.
Date: Tue, 28 Nov 2006 12:16:58 +0300
Message-ID: <20061128091656.GD15083@2ka.mipt.ru>
References: <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <20061121184605.GA7787@2ka.mipt.ru> <4563FE71.4040807@redhat.com> <20061122104416.GD11480@2ka.mipt.ru> <20061123085243.GA11575@2ka.mipt.ru> <456603E7.9090006@redhat.com> <20061124095052.GC13600@2ka.mipt.ru> <456B2C82.7040700@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Alexander Viro <aviro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:20961 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S935736AbWK1JU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 04:20:56 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <456B2C82.7040700@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 27, 2006 at 10:20:50AM -0800, Ulrich Drepper (drepper@redhat.com) wrote:
> sigev_value is a union and the largest element is a pointer.  So, 
> transporting the pointer value is sufficient and it should be passed up 
> to the user in the ptr member of struct ukevent.

That is where I've put it in current version.

-- 
	Evgeniy Polyakov
