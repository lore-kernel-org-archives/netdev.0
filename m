From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2.6 NET] Device name changing via rtnetlink
Date: Fri, 10 Sep 2004 22:43:48 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910204348.GL20088@postel.suug.ch>
References: <20040910195003.GA13912@bougret.hpl.hp.com> <20040910200644.GJ20088@postel.suug.ch> <20040910201302.GA16556@bougret.hpl.hp.com> <20040910202235.GK20088@postel.suug.ch> <20040910203203.GA17078@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
Content-Disposition: inline
In-Reply-To: <20040910203203.GA17078@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Jean Tourrilhes <20040910203203.GA17078@bougret.hpl.hp.com> 2004-09-10 13:32
> On Fri, Sep 10, 2004 at 10:22:35PM +0200, Thomas Graf wrote:
> > 
> > 2) Implement NETDEV_CHANGE, I was actually about to implement this
> >    but it's not directly related to this change and requires the same
> >    effort by the user space application has refetching the link list.
> 
> 	Do you have any info on NETDEV_CHANGE, I've got a potential
> use for it.
> 	(By the way, there are other ways to do it, but if
> NETDEV_CHANGE is the proposed standard, I might as well use it).

Currently call_netdevice_notifiers is called and sends out a
RTM_NEWLINK message with the new interface name to everyone
wanting to be notified. However, ifi_change is kept to 0
so far, which means you have to look what has changed yourself. I'm
not sure if this can be changed without too much troubles but
I will look into it.
