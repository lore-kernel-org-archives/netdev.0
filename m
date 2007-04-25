From: David Miller <davem@davemloft.net>
Subject: Re: sysctls
Date: Wed, 25 Apr 2007 16:47:34 -0700 (PDT)
Message-ID: <20070425.164734.31751639.davem@davemloft.net>
References: <m1ps5sqlv4.fsf@ebiederm.dsl.xmission.com>
	<20070425195319.GA25080@hmsreliant.homelinux.net>
	<20070425145018.f373cc93.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, ebiederm@xmission.com,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38414
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1422987AbXDYXr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 19:47:28 -0400
In-Reply-To: <20070425145018.f373cc93.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 25 Apr 2007 14:50:18 -0700

> On Wed, 25 Apr 2007 15:53:19 -0400
> Neil Horman <nhorman@tuxdriver.com> wrote:
> 
> > I did the optimistic dad sysctl, and have no strict use for numbered sysctls (I
> > was just unaware of the policy).  I'll work up a patch to use
> > register_sysclt_table with CTL_UNNUMBERED in the next few days.
> 
> I don't think you need to add a call to register_sysctl_table(), if that's
> what you're proposing.  Just drop the changes to sysctl.h and use CTL_UNNUMBERED
> in sysctl.c.

Ok, I'll take care of this.
