From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] iproute: Add support for extended ack to rtnl_talk
Date: Fri, 4 Aug 2017 09:47:29 -0700
Message-ID: <20170804094729.00548085@xeon-e3>
References: <590AF624.6090808@iogearbox.net>
        <7315b681-9c78-4bc1-ab74-64509ab5887d@gmail.com>
        <20170504.104103.1628291573330660235.davem@davemloft.net>
        <20170504094356.66590a9a@xeon-e3>
        <20170504204318.GB21130@orbyte.nwl.cc>
        <f847c8d4-a6c0-66ab-0ac0-d83d6ea96a00@gmail.com>
        <20170516093625.178caf3f@xeon-e3>
        <591D711F.1000906@iogearbox.net>
        <1c494983-24e0-cd8f-9a2a-5d2a83e0bbc2@gmail.com>
        <0d84bd27-2fd1-68c0-5787-0195e95ab1af@gmail.com>
        <20170804113147.GA25254@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Phil Sutter <phil@nwl.cc>, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:38904 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752389AbdHDQrc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 12:47:32 -0400
Received: by mail-pg0-f54.google.com with SMTP id l64so10025040pge.5
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 09:47:32 -0700 (PDT)
In-Reply-To: <20170804113147.GA25254@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Aug 2017 13:31:48 +0200
Simon Horman <simon.horman@netronome.com> wrote:

> On Thu, Aug 03, 2017 at 02:26:58PM -0600, David Ahern wrote:
> > On 5/18/17 10:24 PM, David Ahern wrote:  
> > > On 5/18/17 3:02 AM, Daniel Borkmann wrote:  
> > >> So effectively this means libmnl has to be used for new stuff, noone
> > >> has time to do the work to convert the existing tooling over (which
> > >> by itself might be a challenge in testing everything to make sure
> > >> there are no regressions) given there's not much activity around
> > >> lib/libnetlink.c anyway, and existing users not using libmnl today
> > >> won't see/notice new improvements on netlink side when they do an
> > >> upgrade. So we'll be stuck with that dual library mess pretty much
> > >> for a very long time. :(  
> > > 
> > > lib/libnetlink.c with all of its duplicate functions weighs in at just
> > > 947 LOC -- a mere 12% of the code in lib/. From a total SLOC of iproute2
> > > it is a negligible part of the code base.
> > > 
> > > Given that, there is very little gain -- but a lot of risk in
> > > regressions -- in converting such a small, low level code base to libmnl
> > > just for the sake of using a library - something Phil noted in his
> > > cursory attempt at converting ip to libmnl. ie., The level effort
> > > required vs the benefit is just not worth it.
> > > 
> > > There are so many other parts of the ip code base that need work with a
> > > much higher return on the time investment.
> > >   
> > 
> > Stephen: It has been 3 months since the first extack patches were posted
> > and still nothing in iproute2, all of it hung up on your decision to
> > require libmnl. Do you plan to finish the libmnl support any time soon
> > and send out patches?  
> 
> FWIIW I would also like to see some way to get this enhancement accepted.

I will put in the libmnl version. If it doesn't work because no one sent
me test cases, then fine. send a patch for that.
