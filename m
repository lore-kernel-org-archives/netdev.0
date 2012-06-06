From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire X4150(x86)
 and e1000e
Date: Wed, 6 Jun 2012 09:26:35 -0700
Message-ID: <20120606092635.00003b61@unknown>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	<88c43001441945e1431609db252b69e7@visp.net.lb>
	<df211722d18136698aeeda2f17b876e2@visp.net.lb>
	<d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	<CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
	<79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
	<CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
	<20120529232518.e5b41759.shimoda.hiroaki@gmail.com>
	<1338959413.2760.3686.camel@edumazet-glaptop>
	<20120606174303.0bfc9868.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	<netdev@vger.kernel.org>, <e1000-devel@lists.sourceforge.net>,
	<jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14130 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752879Ab2FFQ0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 12:26:36 -0400
In-Reply-To: <20120606174303.0bfc9868.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 Jun 2012 Hiroaki SHIMODA <shimoda.hiroaki@gmail.com> wrote:
> Sorry for long delay. I'll post.
> (I have no idea how to fix this problem as keeping TXDCTL.WTHRESH to 5)

I don't like changing WTHRESH wholesale because making the global change
to WTHRESH on e1000e just to fix this one bug (likely specific to a
particular chip/hardware) will adversely effect performance on many
models supported by e1000e not demonstrating any problem.  We could
possibly check something in for just ESB2LAN (S5000 chipset).

Other people (tom herbert) with this same chipset have been unable to
reproduce this issue right?
