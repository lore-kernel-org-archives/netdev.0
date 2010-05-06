From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Thu, 6 May 2010 16:21:13 -0400
Message-ID: <20100506202113.GC17922@infradead.org>
References: <20100504230225.GP8323@vmware.com> <201005051029.42052.dtor@vmware.com> <20100505173120.GA1752@infradead.org> <201005051035.29831.dtor@vmware.com> <20100505173951.GA8388@infradead.org> <20100505105253.0a8bc465@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Torokhov <dtor@vmware.com>,
	Christoph Hellwig <hch@infradead.org>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	Pankaj Thakkar <pthakkar@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100505105253.0a8bc465@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 05, 2010 at 10:52:53AM -0700, Stephen Hemminger wrote:
> Let me put it bluntly. Any design that allows external code to run
> in the kernel is not going to be accepted.  Out of tree kernel modules are enough
> of a pain already, why do you expect the developers to add another
> interface.

Exactly.  Until our friends at VMware get this basic fact it's useless
to continue arguing.

Pankaj and Dmitry: you're fine to waste your time on this, but it's not
going to go anywhere until you address that fundamental problem.  The
first thing you need to fix in your archicture is to integrate the VF
function code into the kernel tree, and we can work from there.

Please post patches doing this if you want to resume the discussion.
