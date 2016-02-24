From: David Miller <davem@davemloft.net>
Subject: Re: Invalid sk_policy[] access
Date: Tue, 23 Feb 2016 19:23:33 -0500 (EST)
Message-ID: <20160223.192333.2231140701919705299.davem@davemloft.net>
References: <alpine.LRH.2.20.1602232250000.30129@math.ut.ee>
	<20160223.175901.15624631458340642.davem@davemloft.net>
	<20160223235946.GE4941@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mroos@linux.ee, sparclinux@vger.kernel.org, edumazet@google.com,
	netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20160223235946.GE4941@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue, 23 Feb 2016 18:59:46 -0500

> But then it's odd that the struct sizes (esp of things like 
> request_sock, which are not config dependant) are not the same.

Every structure that has a lock, or something that contains a lock
(such as a timer or whatever), has a layout which is config dependant.
And I'm pretty sure request_sock falls into this category.

Any number of debug and lock verification config options can control
the layout of spinlock and other core datastructures.

