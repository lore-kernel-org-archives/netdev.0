From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 00/33] Network Devices Ops (v0.3)
Date: Mon, 17 Nov 2008 17:35:58 -0800
Message-ID: <20081117173558.7d861bcf@extreme>
References: <20081117234207.854110282@vyatta.com>
	<9929d2390811171727m14571c8bg64909d346a3753a0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36546 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751792AbYKRBgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 20:36:02 -0500
In-Reply-To: <9929d2390811171727m14571c8bg64909d346a3753a0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Nov 2008 17:27:05 -0800
"Jeff Kirsher" <jeffrey.t.kirsher@intel.com> wrote:

> On Mon, Nov 17, 2008 at 3:42 PM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> > This sequence of patches breaks the network device adminstration
> > function table away from the network device data structure. It is
> > a transitional API change (both keep working), and this set of patches
> > hits a range of commonly used drivers. This should be enough to make sure
> > both old and new interfaces get used and tested.
> >
> > --
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> 
> Did I miss a patch, or did you intentionally not convert ixgbe?

Since it was so similar to ixgb, both files are patched in same patch bundle.
