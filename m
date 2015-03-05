From: Tom Herbert <therbert@google.com>
Subject: Re: [ovs-dev] OVS Offload Decision Proposal
Date: Wed, 4 Mar 2015 21:20:41 -0800
Message-ID: <CA+mtBx_Q5Zp58ZkBB0oeyHm5NC8sg1kx=uzTN_8TYG6zYh8yUA@mail.gmail.com>
References: <CA+mtBx9U-HUXcfk+oOuNRwpKq74WXmbkWvQDrYURCavfWZjQaQ@mail.gmail.com>
	<3A5015FE9E557D448AF7238AF0ACE20A2D8AE08A@IRVEXCHMB11.corp.ad.broadcom.com>
	<54F7B76E.4040902@gmail.com>
	<20150305.000015.1427044514000703740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: john fastabend <john.fastabend@gmail.com>,
	David Christensen <davidch@broadcom.com>,
	Simon Horman <simon.horman@netronome.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:45487 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074AbbCEFUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 00:20:42 -0500
Received: by iery20 with SMTP id y20so20235820ier.12
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 21:20:42 -0800 (PST)
In-Reply-To: <20150305.000015.1427044514000703740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 4, 2015 at 9:00 PM, David Miller <davem@davemloft.net> wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Wed, 04 Mar 2015 17:54:54 -0800
>
>> I think a set operation _is_ necessary for OVS and other
>> applications that run in user space.
>
> It's necessary for the kernel to internally manage the chip
> flow resources.
>
> Full stop.
>
> It's not being exported to userspace.  That is exactly the kind
> of open ended, outside the model, crap we're trying to avoid
> by putting everything into the kernel where we have consistent
> mechanisms, well understood behaviors, and rules.

David,

Just to make sure everyone is on the same page... this discussion has
been about where the policy of offload is implemented, not just who is
actually sending config bits to the device. The question is who gets
to decide how to best divvy up the finite resources of the device and
network amongst various requestors. Is this what you're referring to?

Thanks,
Tom
