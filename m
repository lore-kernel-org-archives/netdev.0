From: "Ira W. Snyder" <iws@ovro.caltech.edu>
Subject: Re: [PATCH 2/3] can: add support for Janz VMOD-ICAN3 Intelligent
 CAN	module
Date: Fri, 19 Mar 2010 13:03:25 -0700
Message-ID: <20100319200325.GE13672@ovro.caltech.edu>
References: <>
 <1268930324-29841-3-git-send-email-iws@ovro.caltech.edu>
 <4BA33D5A.8070000@grandegger.com>
 <20100319151914.GB13672@ovro.caltech.edu>
 <4BA39C05.8050800@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org, sameo@linux.intel.com
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BA39C05.8050800@grandegger.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 19, 2010 at 04:45:09PM +0100, Wolfgang Grandegger wrote:
> Ira W. Snyder wrote:
> > On Fri, Mar 19, 2010 at 10:01:14AM +0100, Wolfgang Grandegger wrote:
> >> Hi Ira,
> >>
> >> we already discussed this patch on the SocketCAN mailing list and there
> >> are just a few minor issues and the request to add support for the new
> >> "berr-reporting" option, if feasible. See:
> >>
> >>   commit 52c793f24054f5dc30d228e37e0e19cc8313f086
> >>   Author: Wolfgang Grandegger <wg@grandegger.com>
> >>   Date:   Mon Feb 22 22:21:17 2010 +0000
> >>
> >>     can: netlink support for bus-error reporting and counters
> >>     
> >>     This patch makes the bus-error reporting configurable and allows to
> >>     retrieve the CAN TX and RX bus error counters via netlink interface.
> >>     I have added support for the SJA1000. The TX and RX bus error counters
> >>     are also copied to the data fields 6..7 of error messages when state
> >>     changes are reported.
> >>
> >> Should not be a big deal.
> >>
> > 
> > I think this patch came along since my last post of the driver. I must
> > have missed it. I'll try and add support.
> 
> No problem, it's really new. Just just need to enable BEI depending on
> CAN_CTRLMODE_BERR_REPORTING.
> 

I have one final question about this.

The documentation for the firmware isn't very specific here. I believe
that in order to get any kind of error messages, I need the bus error
feature turned on. What is the expected behavior of an SJA1000 with the
BEI (bus error interrupt) turned off? Will you still get warning
messages for ERROR_ACTIVE -> ERROR_PASSIVE state transitions?

I'm not sure how I would go about testing this feature, either. Ideas?

I also noticed that I can enable "self test mode" and "listen only mode"
using the same firmware command. It appears that there are netlink
messages for this as well. Should I try and support these, too? I don't
really have any use for them (yet). I assume "self test mode" is
equivalent to "loopback mode" in the netlink messages.

Thanks,
Ira
