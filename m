From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 4/7] netpoll: fix ->poll() locking
Date: Fri, 22 Apr 2005 15:59:58 -0700
Message-ID: <20050422155958.474a150c.davem@davemloft.net>
References: <4.454130102@selenic.com>
	<5.454130102@selenic.com>
	<17001.31150.194263.732284@segfault.boston.redhat.com>
	<20050422155218.223fa84d.davem@davemloft.net>
	<17001.33427.462497.856777@segfault.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmoyer@redhat.com
In-Reply-To: <17001.33427.462497.856777@segfault.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Apr 2005 19:02:43 -0400
Jeff Moyer <jmoyer@redhat.com> wrote:

> Oh yes, of course.  Somehow I managed to forget that we now squirrel away
> the struct netpoll pointer in the net_device.  Previously you could
> register multiple netpoll clients to one device, and this was useful for
> say doing netconsole and netdump over the same interface.  If we've removed
> this ability, this is a bad thing.  Oh dear...

In such a configuration, how did the netpoll code "tell" who the
receive packets were for or did it send them to all registered
netpoll clients for that device?

Just curious.
