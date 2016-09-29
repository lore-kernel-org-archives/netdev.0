From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC 00/12] Programming Open vSwitch (-like) flows into
 hardware using SwitchDev
Date: Thu, 29 Sep 2016 10:09:05 +0200
Message-ID: <20160929080904.GA24113@penelope.isobedori.kobe.vergenet.net>
References: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMh0Wp6sXN1AxuZjnqycp6SkY732E4O9CRWip5Bydxuj2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        "dev@openvswitch.org" <dev@openvswitch.org>,
        Rony Efraim <ronye@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35358 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751220AbcI2IJI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 04:09:08 -0400
Received: by mail-wm0-f47.google.com with SMTP id b4so10737724wmb.0
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 01:09:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMh0Wp6sXN1AxuZjnqycp6SkY732E4O9CRWip5Bydxuj2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Or,

On Wed, Sep 28, 2016 at 04:54:40PM +0300, Or Gerlitz wrote:
> On Wed, Sep 28, 2016 at 3:42 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
> 
> > A different approach, not implemented by this patch-set, is for user-space
> > to program flows into hardware by some other means, for example TC, and/or
> > the (kernel) datapath.
> 
> Right, and we've submitted that code to the OVS community 24h ago [1].
> 
> This was done along the feedback we've got for the last two years (since
> the  LPC 2014 networking micro-conf). It allows offloading from
> multiple user-space
> applications through a single UAPI -- the TC one (currently we did
> flower, but the OVSD
> patch set can be extended to use whatever TC offloads are supported by
> the port driver,
> e.g U32, eBPF) and integration with 3rd party policy modules  running
> in user-space.
> 
> Lets hear people opinions and see where we go from now.
> 
> > I believe that approach does not conflict with this one.
> >  And there is some scope to share infrastructure in the kernel
> 
> maybe, possibly
> 
> We've having a talk in netdev 1.2 on offloading HW offloading of OVS
> and similar applications,
> I would encourage people to come and approach me and/or Rony Efraim
> from Mellanox before/after
> the talk to discuss that F2F, would love to get feedbacks, and also here...

Thanks for putting my post in context with the work you mention.
I am looking forward to some F2F discussions next week.

> Or.
> 
> [1] pointers to patches implementing the 2nd approach
> 
> cover-letter http://openvswitch.org/pipermail/dev/2016-September/079952.html
> 
> patches
> 
> https://patchwork.ozlabs.org/patch/675560/
> https://patchwork.ozlabs.org/patch/675567/
> https://patchwork.ozlabs.org/patch/675565/
> https://patchwork.ozlabs.org/patch/675559/
> https://patchwork.ozlabs.org/patch/675564/
> https://patchwork.ozlabs.org/patch/675563/
> https://patchwork.ozlabs.org/patch/675568/
> https://patchwork.ozlabs.org/patch/675566/
> https://patchwork.ozlabs.org/patch/675562/
> 
> [2] http://www.netdevconf.org/1.2/session.html?rony-efraim-1
