From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Tue, 13 Jul 2010 17:31:00 -0700
Message-ID: <20100713173100.1d4fb42d@nehalam>
References: <20100504230225.GP8323@vmware.com>
	<201005051029.42052.dtor@vmware.com>
	<20100505173120.GA1752@infradead.org>
	<201005051035.29831.dtor@vmware.com>
	<20100505173951.GA8388@infradead.org>
	<20100505105253.0a8bc465@nehalam>
	<20100506202113.GC17922@infradead.org>
	<1278990388.32650.22.camel@eng-rhel5-64>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	Pankaj Thakkar <pthakkar@vmware.com>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59018 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751525Ab0GNAbF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jul 2010 20:31:05 -0400
In-Reply-To: <1278990388.32650.22.camel@eng-rhel5-64>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Jul 2010 20:06:28 -0700
Shreyas Bhatewara <sbhatewara@vmware.com> wrote:

> 
> On Thu, 2010-05-06 at 13:21 -0700, Christoph Hellwig wrote:
> > On Wed, May 05, 2010 at 10:52:53AM -0700, Stephen Hemminger wrote:
> > > Let me put it bluntly. Any design that allows external code to run
> > > in the kernel is not going to be accepted.  Out of tree kernel modules are enough
> > > of a pain already, why do you expect the developers to add another
> > > interface.
> > 
> > Exactly.  Until our friends at VMware get this basic fact it's useless
> > to continue arguing.
> > 
> > Pankaj and Dmitry: you're fine to waste your time on this, but it's not
> > going to go anywhere until you address that fundamental problem.  The
> > first thing you need to fix in your archicture is to integrate the VF
> > function code into the kernel tree, and we can work from there.
> > 
> > Please post patches doing this if you want to resume the discussion.
> > 
> > _______________________________________________
> > Pv-drivers mailing list
> > Pv-drivers@vmware.com
> > http://mailman2.vmware.com/mailman/listinfo/pv-drivers
> 
> 
> As discussed, following is the patch to give you an idea
> about implementation of NPA for vmxnet3 driver. Although the
> patch is big, I have verified it with checkpatch.pl. It gave
> 0 errors / warnings.
> 
> Signed-off-by: Matthieu Bucchaineri <matthieu@vmware.com>
> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
> ---

I am surprised, the code seems to use lots of mixed case in places
that don't really follow current kernel practice.

