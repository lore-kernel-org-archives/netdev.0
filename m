From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next-2.6] bridge: allow hub-like behaviour
Date: Thu, 12 Aug 2010 08:55:20 -0400
Message-ID: <20100812085520.4f56ebe6@s6510>
References: <20100811144017.GA2625@psychotron.brq.redhat.com>
	<20100811120741.27e13248@s6510>
	<20100812111523.GC3115@psychotron.brq.redhat.com>
	<20100812083541.33d8759a@s6510>
	<20100812124847.GD3115@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	bridge@lists.linux-foundation.org, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:32837 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753370Ab0HLMzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Aug 2010 08:55:23 -0400
In-Reply-To: <20100812124847.GD3115@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Aug 2010 14:48:48 +0200
Jiri Pirko <jpirko@redhat.com> wrote:

> Thu, Aug 12, 2010 at 02:35:41PM CEST, shemminger@vyatta.com wrote:
> >On Thu, 12 Aug 2010 13:15:24 +0200
> >Jiri Pirko <jpirko@redhat.com> wrote:
> >
> >> Wed, Aug 11, 2010 at 06:07:41PM CEST, shemminger@vyatta.com wrote:
> >> >NO. unnecessary
> >> >
> >> >Already possible, without patch. Just set the hold time
> >> >on the bridge to 0!
> >> 
> >> Sorry, but could you please point me a sysfs node where should I do this
> >> setting? Unable to find this.
> >> 
> >> Thanks.
> >> 
> >
> >/sys/class/net/ethX/brport/hold_timer
> 
> That's read-only:
> 
> static BRPORT_ATTR(hold_timer, S_IRUGO, show_hold_timer, NULL);
> 

Guess you have to use ioctl() interface to change it for now.
Looks like a missed opportunity when sysfs support was added.
There are some other values like forward_delay that have same problem.
