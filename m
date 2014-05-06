From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 11:58:38 -0700
Message-ID: <CA+mtBx81EdtZeXRG_ubgWMy+8rSOpK3q0S3YktBDDFt-LG2poA@mail.gmail.com>
References: <1399328773-6531-9-git-send-email-andi@firstfloor.org>
	<20140505.231229.136734008603421707.davem@davemloft.net>
	<20140506032114.GP2382@two.firstfloor.org>
	<20140505.232327.578134514220748085.davem@davemloft.net>
	<20140506155703.GA20391@cloud>
	<1399394359.15399.20.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140506183216.GM19657@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, josh@joshtriplett.org,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, tom.zanussi@linux.intel.com
To: Andi Kleen <ak@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:36310 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbaEFS6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 14:58:39 -0400
Received: by mail-ie0-f178.google.com with SMTP id lx4so9860989iec.23
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 11:58:38 -0700 (PDT)
In-Reply-To: <20140506183216.GM19657@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 6, 2014 at 11:32 AM, Andi Kleen <ak@linux.intel.com> wrote:
>> We simply can not compete with user space, as a programmer is free to
>> keep what he really wants/needs.
>
> Not true.
>
> With my patches and LTO Linux can be competive with LWIP+socket layer.
> (about 60K more text). And it's easier to use because it's just
> the standard interface.
>
>> I have started using linux on 386/486 pcs which had more than 2MB of
>> memory, it makes me sad we want linux-3.16 to run on this kind of
>> hardware, and consuming time to save few KB here and here.
>
> Linux has always been a system from very small to big.
> That's been one of its strengths. It is very adaptable.
>
> Many subsystems are very configurable for this.
> For example that is why we have both SLOB and SLUB.
> That is why we have NOMMU MM and lots of other tuning
> knobs for small systems.
>
> So if the other subsystems can do this, why should it be
> impossible for networking?
>
Can this at least be done without the combinatorial explosion in
number of configurations? As Yuchung pointed out these patches
introduce at least one unresolved configuration dependency. CONFIG_SMP
works quite well since with a single parameter we can enable/disable a
whole bunch of functionality in bulk, and it's quite clear that new
development cannot break smp or non-smp configurations. Maybe you want
something similar like CONFIG_NETWORK_SMALL?

Tom

> -Andi
>
> --
> ak@linux.intel.com -- Speaking for myself only
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
