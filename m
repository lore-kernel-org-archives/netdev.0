From: "David S. Miller" <davem@davemloft.net>
Subject: Re: tcp heisenbug
Date: Fri, 8 Oct 2004 12:25:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008122548.544a3329.davem@davemloft.net>
References: <20041008014151.26e17547.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20041008014151.26e17547.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 8 Oct 2004 01:41:51 -0700
Andrew Morton <akpm@osdl.org> wrote:

> fetchmail broke.  It's fetching mail from localhost (ssh port-forwarded to
> remote servers) and then for some reason it wants to open an SMTP
> connection to localhost.  It was failing, some error message about that
> SMTP connection.
> 
> While I was poking at it, it started to work.  `uptime' said 6 minutes.  So
> I'd be suspecting that there's a jiffy wrap bug in TCP-to-localhost
> introduced since 2.6.9-rc3.

That's possible.

It could also be something that only happens the first time you try
to talk to a remote system.

You're using e1000 on x86 right?  Maybe force TSO off via ethtool
right after the interface is brought up and see if that makes it
go away?
