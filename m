From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC/PATCH 3/3] UDP memory usage accounting (take 2): measurement
Date: Fri, 28 Sep 2007 18:37:12 +0400
Message-ID: <20070928143710.GA16747@2ka.mipt.ru>
References: <46FD048B.9010409@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev <netdev@vger.kernel.org>,
	=?utf8?B?5ZCJ6JekIOiLseaYjg==?= <yoshfuji@linux-ipv6.org>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	=?utf8?B?6Z2S5pyoQFJlZEhhdA==?= <haoki@redhat.com>
To: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51912 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755123AbXI1Ohw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 10:37:52 -0400
Content-Disposition: inline
In-Reply-To: <46FD048B.9010409@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 28, 2007 at 10:41:31PM +0900, Satoshi OSHIMA (satoshi.oshima.fk@hitachi.com) wrote:
> This patch introduces memory usage measurement for UDP.
> 
> These 3 points were updated.
> 
> - UDP specific codes in IP layer were removed.
> 
> - atomic_sub() in a loop was removed
> 
> - accounting during socket destruction

Another approach is to account only at the highest UDP layer and having
datagram skb destructor just like it is done in TCP, but this approach
is also resonable.

I already told that patches 1 and 3 have broken indent, please fix that.

A hint: when you are about to submit something network related for inclusion,
and strongly believes it is ready, it can be a not that bad idea to add 
David Miller <davem@davemloft.net> to copy list, he can complain about
backlog and so on, but will read you mail twice :) but do not tell anyone.

-- 
	Evgeniy Polyakov
