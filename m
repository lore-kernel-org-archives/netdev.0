From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: Re: [PATCH v2 -mm 8/9] netconsole: Support multiple logging targets
Date: Wed, 11 Jul 2007 03:47:09 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707110340370.2445@cselinux1.cse.iitk.ac.in>
References: <20070710091920.23907.96483.sendpatchset@cselinux1.cse.iitk.ac.in>
  <20070710092001.23907.39876.sendpatchset@cselinux1.cse.iitk.ac.in>
 <e9e943910707100323o35cb0316i5d3f21584ad8e4ae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Matt Mackall <mpm@selenic.com>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Duane Griffin <duaneg@dghda.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752896AbXGKEEd@vger.kernel.org>
In-Reply-To: <e9e943910707100323o35cb0316i5d3f21584ad8e4ae@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, 10 Jul 2007, Duane Griffin wrote:
> On 10/07/07, Satyam Sharma <ssatyam@cse.iitk.ac.in> wrote:
> > +       /* Avoid taking lock and disabling interrupts unnecessarily */
> > +       if (unlikely(list_empty(&target_list)))
> > +               return;
> 
> Is the unlikely a good idea here? Not having any targets may be
> unusual but it isn't ridiculous. It might even be a sensible default
> for distros.

Hmm, I put it in there because I expected that the user must have had
at least one target configured (added to target_list) if he's got the
module loaded/built-in (and netconsole registered), which is when this
function would be triggered anyway.

> My (very limited) understanding of unlikely is that it
> could impose a very large penalty in that case and would make a very
> marginal difference at best in the common case.

I wouldn't call it a large penalty, but yeah, probably the unlikely()
there isn't all that important either.

Satyam
