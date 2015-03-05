From: David Miller <davem@davemloft.net>
Subject: Re: [ovs-dev] OVS Offload Decision Proposal
Date: Thu, 05 Mar 2015 00:00:15 -0500 (EST)
Message-ID: <20150305.000015.1427044514000703740.davem@davemloft.net>
References: <CA+mtBx9U-HUXcfk+oOuNRwpKq74WXmbkWvQDrYURCavfWZjQaQ@mail.gmail.com>
	<3A5015FE9E557D448AF7238AF0ACE20A2D8AE08A@IRVEXCHMB11.corp.ad.broadcom.com>
	<54F7B76E.4040902@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidch@broadcom.com, therbert@google.com,
	simon.horman@netronome.com, dev@openvswitch.org,
	netdev@vger.kernel.org, pablo@netfilter.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52752 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698AbbCEFAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 00:00:17 -0500
In-Reply-To: <54F7B76E.4040902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Wed, 04 Mar 2015 17:54:54 -0800

> I think a set operation _is_ necessary for OVS and other
> applications that run in user space.

It's necessary for the kernel to internally manage the chip
flow resources.

Full stop.

It's not being exported to userspace.  That is exactly the kind
of open ended, outside the model, crap we're trying to avoid
by putting everything into the kernel where we have consistent
mechanisms, well understood behaviors, and rules.
