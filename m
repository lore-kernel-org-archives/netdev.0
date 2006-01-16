From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [patch] networking ipv4: remove total socket usage count from /proc/net/sockstat
Date: Mon, 16 Jan 2006 15:25:30 -0500
Message-ID: <bdfc5d6e0601161225h53554b1ahde794af93af52bdf@mail.gmail.com>
References: <20060116200432.GB14060@gospo.rdu.redhat.com>
	 <1137442446.19444.20.camel@mindpipe>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751191AbWAPUZc@vger.kernel.org>
To: Lee Revell <rlrevell@joe-job.com>
In-Reply-To: <1137442446.19444.20.camel@mindpipe>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

What userspace app will break because of this?

On 1/16/06, Lee Revell <rlrevell@joe-job.com> wrote:
> On Mon, 2006-01-16 at 15:04 -0500, Andy Gospodarek wrote:
> > Printing the total number of sockets used in /proc/net/sockstat is out
> > of place in a file that is supposed to contain information related to
> > ipv4 sockets.  Removed output for total socket usage.
> >
>
> Um, you can't do that, it will break userspace.
>
> Lee
>
>
