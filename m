From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into
 hardware
Date: Thu, 09 Feb 2012 16:11:34 -0500
Message-ID: <1328821894.2089.3.camel@mojatatu>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>
	 <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>
	 <4F34042F.6090806@intel.com>
	 <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>
	 <4F3407F7.9000202@intel.com>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44376 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825Ab2BIVLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 16:11:38 -0500
In-Reply-To: <4F3407F7.9000202@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-02-09 at 09:52 -0800, John Fastabend wrote:

> >> By netlink_notifier do you mean adding a notifier_block and using atomic_notifier_call_chain()
> >> probably in rtnl_notify()? Then drivers could register with the notifier chain with
> >> atomic_notifier_chain_register() and receive the events correctly. Or did I miss
> >> some notifier chain that already exists?
> > 
> > Yes. that is what I mean. The callbacks you need may or may not already be present.

I'll go one step further.
This stuff shouldnt be in the kernel at all. 
The disadvantage is you need a user space app to update the hardware.
i.e, the same mechanism should be usable for either a switch embedded
in a NIC or a standalone hardware switch (with/out the s/ware bridge 
presence)

cheers,
jamal
