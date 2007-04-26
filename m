From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: sysctls
Date: Thu, 26 Apr 2007 07:12:51 -0400
Message-ID: <20070426111251.GA29377@hmsreliant.homelinux.net>
References: <m1ps5sqlv4.fsf@ebiederm.dsl.xmission.com> <20070425195319.GA25080@hmsreliant.homelinux.net> <20070425145018.f373cc93.akpm@linux-foundation.org> <20070425.164734.31751639.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, ebiederm@xmission.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3908 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754537AbXDZLN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 07:13:59 -0400
Content-Disposition: inline
In-Reply-To: <20070425.164734.31751639.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 25, 2007 at 04:47:34PM -0700, David Miller wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Wed, 25 Apr 2007 14:50:18 -0700
> 
> > On Wed, 25 Apr 2007 15:53:19 -0400
> > Neil Horman <nhorman@tuxdriver.com> wrote:
> > 
> > > I did the optimistic dad sysctl, and have no strict use for numbered sysctls (I
> > > was just unaware of the policy).  I'll work up a patch to use
> > > register_sysclt_table with CTL_UNNUMBERED in the next few days.
> > 
> > I don't think you need to add a call to register_sysctl_table(), if that's
> > what you're proposing.  Just drop the changes to sysctl.h and use CTL_UNNUMBERED
> > in sysctl.c.
> 
> Ok, I'll take care of this.
Thank you dave.
Neil

