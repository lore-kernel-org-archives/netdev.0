From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: act_api: Fix module leak while flushing actions
Date: Sun, 9 Jul 2006 21:57:34 +0200
Message-ID: <20060709195734.GP14627@postel.suug.ch>
References: <20060709142043.GN14627@postel.suug.ch> <20060709.113858.01310628.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:57320 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1161091AbWGIT5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2006 15:57:13 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060709.113858.01310628.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> 2006-07-09 11:38
> From: Thomas Graf <tgraf@suug.ch>
> Date: Sun, 9 Jul 2006 16:20:43 +0200
> 
> > Module reference needs to be given back if message header
> > construction fails.
> > 
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Applied, thanks Thomas.
> 
> This reminds me of something, not only are non-networking developers
> getting tripped up constantly about these magic code labels referenced
> from the netlink macros, they are tripping us up as well.
> 
> I really think it's time, at a minimum, to explicitly mention the
> labels as an argument to the macros, or something like that.
> 
> I'll try to cons something up when I get a chance.  The current
> situation is too error prone.

I agree, that's why the new netlink api offers label free
methods. The transformation patches for 2.6.19 converting
all netlink users to use the new api will resolved these
issues.
