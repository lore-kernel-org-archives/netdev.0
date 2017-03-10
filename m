From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: amd-xgbe: unbalanced irq enable in v4.11-rc1
Date: Fri, 10 Mar 2017 18:04:34 +0000
Message-ID: <20170310180434.GC24571@leverpostej>
References: <20170310171953.GA24571@leverpostej>
 <6ded1511-af84-e406-7e86-dd84972c451d@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6ded1511-af84-e406-7e86-dd84972c451d@amd.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 10, 2017 at 11:39:42AM -0600, Tom Lendacky wrote:
> On 3/10/2017 11:19 AM, Mark Rutland wrote:
> >Hi,
> >
> >I'm seeing the below splat when transferring data over the network, using
> >v4.11-rc1 on an AMD Seattle platform. I don't see the splat with v4.10.
> >
> >Looking at just the driver, I couldn't see any suspicious changes. Reverting
> >commit 402168b4c2dc0734 ("amd-xgbe: Stop the PHY before releasing interrupts")
> >doesn't change matters.
> >
> >Any ideas?
> 
> Yes, patch submitted.  Please see:
> 
> 	http://marc.info/?l=linux-netdev&m=148910333810442&w=2

Ah, thanks for the pointer!

That appears to solve the issue for me.

Thanks,
Mark.
