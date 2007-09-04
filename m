From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: 2.6.23-rc4-mm1
Date: Tue, 4 Sep 2007 22:36:08 +0100
Message-ID: <20070904223608.4e608930@oldman>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
	<200709041054.32859.linux@zachcarter.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Zach Carter <linux@zachcarter.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49823 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755069AbXIDVfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 17:35:31 -0400
In-Reply-To: <200709041054.32859.linux@zachcarter.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 4 Sep 2007 10:54:32 -0700
Zach Carter <linux@zachcarter.com> wrote:

> 
> > +ioc3-program-uart-predividers.patch
> > +sky2-fe-chip-support.patch
> > +sky2-use-debugfs-rename.patch
> > +sky2-document-gphy_ctrl-bits.patch
> > +sky2-dont-restrict-config-space-access.patch
> > +sky2-advanced-error-reporting.patch
> > +sky2-use-pci_config-access-functions.patch
> > +sky2-use-net_device-internal-stats.patch
> > +ktime_sub_ns-analog-of-ktime_add_ns.patch
> > +export-reciprocal_value-for-modules.patch
> > +sky2-hardware-receive-timestamp-counter.patch

I already told Andrew to please drop this last patch, because
it causes interrupt messages. It seems masking off the IRQ
in hardware doesn't prevent that interrupt!
