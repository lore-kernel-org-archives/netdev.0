From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/33] Network Devices Ops (v0.3)
Date: Wed, 19 Nov 2008 14:04:44 -0800 (PST)
Message-ID: <20081119.140444.179873784.davem@davemloft.net>
References: <9929d2390811171727m14571c8bg64909d346a3753a0@mail.gmail.com>
	<20081117173558.7d861bcf@extreme>
	<9929d2390811191355k247ac638l4cb98f9c3cdc237f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53292
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750716AbYKSWEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 17:04:45 -0500
In-Reply-To: <9929d2390811191355k247ac638l4cb98f9c3cdc237f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Date: Wed, 19 Nov 2008 13:55:12 -0800

> On Mon, Nov 17, 2008 at 5:35 PM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> > On Mon, 17 Nov 2008 17:27:05 -0800
> > "Jeff Kirsher" <jeffrey.t.kirsher@intel.com> wrote:
> >
> >> On Mon, Nov 17, 2008 at 3:42 PM, Stephen Hemminger
> >> <shemminger@vyatta.com> wrote:
> >> > This sequence of patches breaks the network device adminstration
> >> > function table away from the network device data structure. It is
> >> > a transitional API change (both keep working), and this set of patches
> >> > hits a range of commonly used drivers. This should be enough to make sure
> >> > both old and new interfaces get used and tested.
> >> >
> >> >
> >>
> >> Did I miss a patch, or did you intentionally not convert ixgbe?
> >
> > Since it was so similar to ixgb, both files are patched in same patch bundle.
> > --
> >
> 
> Looking at this further, what is the benefit of this change?  For this
> massive of a change, I would expect some sort of significant benefit.
> 
> What is the driving force behind this change?

If you have 1,000 virtual MAC vlan devices, you have 1,000 copies of
these ops pointers being accessed by the CPU, that's stupid.

It's just one of many examples.
