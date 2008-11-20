From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 00/33] Network Devices Ops (v0.3)
Date: Wed, 19 Nov 2008 19:02:12 -0800
Message-ID: <20081119190212.6d589358@extreme>
References: <20081117234207.854110282@vyatta.com>
	<20081119.173353.251644773.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44587 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751920AbYKTDCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 22:02:16 -0500
In-Reply-To: <20081119.173353.251644773.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Nov 2008 17:33:53 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, 17 Nov 2008 15:42:07 -0800
> 
> > This sequence of patches breaks the network device adminstration 
> > function table away from the network device data structure. It is
> > a transitional API change (both keep working), and this set of patches
> > hits a range of commonly used drivers. This should be enough to make sure
> > both old and new interfaces get used and tested.
> 
> I'm starting to apply these patches, thanks Stephen.
> 
> I really think we should move even fast-path function pointers
> here.  When we have tons of virtual devices configured, it
> doesn't make sense for us to touch tons of ->hard_start_xmit
> pointer values which all evaluate to the same thing.
> 
> ops are ops

I have some more pending. I'll add neigh_setup and xmit stuff.
