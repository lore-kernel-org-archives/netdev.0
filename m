From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Thousands of interfaces
Date: Tue, 31 Oct 2006 10:22:22 -0800
Message-ID: <20061031102222.7ab1ed6b@freekitty>
References: <20061031092550.GA8201@tufnell.london.poggs.net>
	<20061031.013154.122620846.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: peter.hicks@poggs.co.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25305 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423763AbWJaSWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 13:22:30 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061031.013154.122620846.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 31 Oct 2006 01:31:54 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Peter Hicks <peter.hicks@poggs.co.uk>
> Date: Tue, 31 Oct 2006 09:25:50 +0000
> 
> [ Discussion belongs on netdev@vger.kernel.org, added to CC: ]
> 
> > I have a dual 3GHz Xeon machine with a 2.4.21 kernel and thousands (15k+) of
> > ipip tunnel interfaces.  These are being used to tunnel traffic from remote
> > routers, over a private network, and handed off to a third party.
>  ...
> > Is it possible to speed up creation of the interfaces?  Currently it takes
> > around 24 hours.  Is there are more efficient way to handle a very large
> > number of IP-IP tunnels?  Would upgrading to a 2.6 kernel be of use?
> 


2.4 has a several N^2 searches for interfaces (and is in deep freeze by now).
2.6 had several changes to handle 1000's of interfaces.


-- 
Stephen Hemminger <shemminger@osdl.org>
