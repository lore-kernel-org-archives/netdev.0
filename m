From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: ixgbe: RTNL assertion failed
Date: Fri, 3 May 2013 20:51:21 -0700
Message-ID: <20130503205121.5b81a355@nehalam.linuxnetplumber.net>
References: <20130503120907.4f13d41b@nehalam.linuxnetplumber.net>
	<F6FB0E698C9B3143BDF729DF222866464C28E112@ORSMSX110.amr.corp.intel.com>
	<20130504015406.GP2619@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:46101 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746Ab3EDDvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 23:51:40 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq8so1182912pbb.33
        for <netdev@vger.kernel.org>; Fri, 03 May 2013 20:51:39 -0700 (PDT)
In-Reply-To: <20130504015406.GP2619@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 4 May 2013 02:54:06 +0100
Ben Hutchings <ben@decadent.org.uk> wrote:

> On Fri, May 03, 2013 at 11:17:39PM +0000, Skidmore, Donald C wrote:
> > > -----Original Message-----
> > > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > > owner@vger.kernel.org] On Behalf Of Stephen Hemminger
> > > Sent: Friday, May 03, 2013 12:09 PM
> > > To: Kirsher, Jeffrey T
> > > Cc: netdev@vger.kernel.org
> > > Subject: ixgbe: RTNL assertion failed
> > > 
> > > Running 3.9 kernel, ixgbe is splatting on resume from suspend.
> > > 
> > > [26430.213254] ixgbe 0000:01:00.0: setting latency timer to 64 [26430.213257]
> > > RTNL: assertion failed at /build/buildd-linux_3.2.41-2-amd64-Wvc92F/linux-
> > > 3.2.41/net/core/dev.c (1758) [26430.213259] Pid: 7839, comm: kworker/u:1
> > > Not tainted 3.2.0-4-amd64 #1 Debian 3.2.41-2 [26430.213261] Call Trace:
> [...]
> > I'm having a little problem finding a path were we call netif_set_real_num_tx_queues without holding RTNL in net-next.  While looking over the stack dump one of our engineers noticed the text "Not tainted 3.2.0-4-amd64 #1 Debian 3.2.41-2 ".  Could this mean I'm looking over the wrong source?  It would make me feel better as I'm not seeing anything as is. :)
> 
> Indeed, this is not 3.9.
> 
> The version of ixgbe in this Debian kernel has bql support backported,
> but is otherwise the same as in 3.2.41.  I assume that this bug has
> been fixed some time between 3.2 and 3.9, but no-one requested that
> the fix be included in stable branches.  Please can you identify the
> fix?
> 
> Ben.
> 

Yeah, it was a Debian kernel, thought it was 3.9, must have been swapping kernels.
