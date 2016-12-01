From: Florian Westphal <fw@strlen.de>
Subject: Re: [flamebait] xdp, well meaning but pointless
Date: Thu, 1 Dec 2016 17:06:04 +0100
Message-ID: <20161201160604.GD17239@breakpoint.cc>
References: <20161201091108.GF26507@breakpoint.cc>
 <20161201145834.GA569@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:53016 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750789AbcLAQJI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:09:08 -0500
Content-Disposition: inline
In-Reply-To: <20161201145834.GA569@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf <tgraf@suug.ch> wrote:
> On 12/01/16 at 10:11am, Florian Westphal wrote:
> > Aside from this, XDP, like DPDK, is a kernel bypass.
> > You might say 'Its just stack bypass, not a kernel bypass!'.
> > But what does that mean exactly?  That packets can still be passed
> > onward to normal stack?
> > Bypass solutions like netmap can also inject packets back to
> > kernel stack again.
> 
> I have a fundamental issue with the approach of exporting packets into
> user space and reinjecting them: Once the packet leaves the kernel,
> any security guarantees are off. I have no control over what is
> running in user space and whether whatever listener up there has been
> compromised or not. To me, that's a no go, in particular for servers
> hosting multi tenant workloads. This is one of the main reasons why
> XDP, in particular in combination with BPF, is very interesting to me.

Funny, I see it exactly the other way around :)

To me packet coming from this "userspace injection" is no different than
a tun/tap, or any other packet coming from network.

I see no change or increase in attack surface.
