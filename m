From: "David S. Miller" <davem@redhat.com>
Subject: Re: assertion failure at net/sched/sch_generic.c(530)
Date: Tue, 23 Sep 2003 17:08:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923170858.3c3b0b8e.davem@redhat.com>
References: <3F70E12A.1090204@pacbell.net>
	<20030923170216.32eaff53.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: david-b@pacbell.net, hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030923170216.32eaff53.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 23 Sep 2003 17:02:16 -0700
"David S. Miller" <davem@redhat.com> wrote:

> On Tue, 23 Sep 2003 17:11:22 -0700
> David Brownell <david-b@pacbell.net> wrote:
> 
> >    KERNEL: assertion (dev->qdisc_list == NULL) failed at
> >    net/sched/sch_generic.c(530)
> 
> Crap, I think I know what made this start happening.

Wait, David do you have CONFIG_NET_SCHED enabled in your
config?

Qdiscs don't get unlinked in qdisc_destroy() unless that config
is enabled.  If you have it off, that explains the bug and the
fix is obvious.
