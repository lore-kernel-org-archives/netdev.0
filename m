From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take25 1/6] kevent: Description.
Date: Fri, 24 Nov 2006 19:31:00 +0300
Message-ID: <20061124163100.GA21462@2ka.mipt.ru>
References: <11641265982190@2ka.mipt.ru> <4564E162.8040901@redhat.com> <20061123115240.GA20294@2ka.mipt.ru> <4565FA60.9000402@redhat.com> <20061124110143.GF13600@2ka.mipt.ru> <456718A3.1070108@redhat.com> <20061124161406.GA5054@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:60336 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S934199AbWKXQcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Nov 2006 11:32:42 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <20061124161406.GA5054@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 24, 2006 at 07:14:06PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> If kernel has put data asynchronously it will setup special flag, thus 
> kevent_wait() will not sleep and will return, so thread will check new
> entries and process them.

For the clarification - only kevent_wait() updates index, userspace
will not detect that it has changed after thread has put there new
data.
In case kernel thread will updated index too, you are correct,
kevent_wait() should get index as parameter.

-- 
	Evgeniy Polyakov
