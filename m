From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: Re: [PATCH v2 -mm 4/9] netconsole: Add some useful tips to documentation
Date: Wed, 11 Jul 2007 03:40:22 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707110256220.2445@cselinux1.cse.iitk.ac.in>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070710091941.23907.45658.sendpatchset@cselinux1.cse.iitk.ac.in>
 <20070710094142.GM11115@waste.org> <200707101434.39938.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Matt Mackall <mpm@selenic.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Jesper Juhl <jesper.juhl@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751559AbXGKEEz@vger.kernel.org>
In-Reply-To: <200707101434.39938.jesper.juhl@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jesper,

On Tue, 10 Jul 2007, Jesper Juhl wrote:
> On Tuesday 10 July 2007 11:41:43 Matt Mackall wrote:
> > On Tue, Jul 10, 2007 at 02:49:41PM +0530, Satyam Sharma wrote:
> > > From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> > >
> > > [4/9] netconsole: Add some useful tips to documentation
> > >
> > > Add some useful general-purpose tips.
> > >
> > > Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> > > Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>
> >
> > Acked-by: Matt Mackall <mpm@selenic.com>
> >
> > As long as we're on the subject, I've been meaning to add a note
> > telling people to set their console log level to something useful, as
> > having that set too low is the most common problem people encounter.
> 
> How about this?
> [...]
> +Some people forget to raise the kernels log_level to an
> +appropriate level and thus don't see all the kernel log messages they
> +expect. You can add the kernel boot option "ignore_loglevel" to see all
> +messages or you can use SysRq to set the log level to a specific value.
> +

IMHO something that mentions /proc/sys/kernel/printk would be better.

You don't need to have built with SysRq support for that, it's clearly
more flexible than the ignore_loglevel option and wouldn't require a
reboot either. I'll send out an updated patch shortly.

Satyam
