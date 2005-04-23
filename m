From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 4/7] netpoll: fix ->poll() locking
Date: Fri, 22 Apr 2005 22:12:57 -0700
Message-ID: <20050422221257.5df9633a.davem@davemloft.net>
References: <4.454130102@selenic.com>
	<5.454130102@selenic.com>
	<17001.31150.194263.732284@segfault.boston.redhat.com>
	<20050422155218.223fa84d.davem@davemloft.net>
	<17001.33427.462497.856777@segfault.boston.redhat.com>
	<20050422155958.474a150c.davem@davemloft.net>
	<20050423021440.GZ21897@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jmoyer@redhat.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20050423021440.GZ21897@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Apr 2005 19:14:40 -0700
Matt Mackall <mpm@selenic.com> wrote:

> > In such a configuration, how did the netpoll code "tell" who the
> > receive packets were for or did it send them to all registered
> > netpoll clients for that device?
> 
> It walked a global list of clients.

Ok, we definitely need to fix this.
