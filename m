From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [RFC PATCH] net: Add support for virtual machine device queues (VMDQ)
Date: Tue, 28 Aug 2012 00:39:46 +0300
Message-ID: <CAJZOPZJXhCAcZx0gzNWrjU0+VF7q7NkGGFRvrxjDxG8gE73hzQ@mail.gmail.com>
References: <20120718220544.22619.97136.stgit@i40e.jf1>
	<CAJZOPZJBhDdQp2-8WG-UsToPHwyawYYVctqjZMT8JN85DK3XYQ@mail.gmail.com>
	<503A7462.1030803@intel.com>
	<CAJZOPZJyXnHymw4D4VWAajc7Q1EeSaTHRYn7p9sKG2hiHGjr_A@mail.gmail.com>
	<503BAC98.2070508@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Ali Ayoub <ali@mellanox.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:47689 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753222Ab2H0Vjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2012 17:39:47 -0400
Received: by ialo24 with SMTP id o24so9197420ial.19
        for <netdev@vger.kernel.org>; Mon, 27 Aug 2012 14:39:47 -0700 (PDT)
In-Reply-To: <503BAC98.2070508@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Fastabend <john.r.fastabend@intel.com> wrote:
> Or Gerlitz wrote:
>> John Fastabend <john.r.fastabend@intel.com> wrote:

>>> That seems reasonable to me. Adding a 'sub' argument to the set
>>> routines should do it. Also the 'get' routines would need to be
>>> extended to report back these virtual net devices.
>>>
>>> int (*ndo_set_vf_mac)(struct net_device *dev, int vf, int sub, u8* mac);
>>> int (*ndo_set_vf_vlan)(struct net_device *dev,
>>>                         int vf, int sub, u16 vlan, u8 qos);
>>> int (*ndo_set_vf_tx_rate)(struct net_device *dev,
>>>                            int vf, int sub, int rate);
>>> int (*ndo_set_vf_spoofchk)(struct net_device *dev,
>>>                             int vf, int sub, bool setting);
>>> int (*ndo_get_vf_config)(struct net_device *dev,
>>>                           int vf, int sub,
>>>                           struct fila_vf_info *ivf)

>>> I would need to check if any of the ixgbe/igb supported hardware can
>>> support virtual device queues on virtual functions like this but I
>>> presume if your looking at this you have some hardware that can.

>> Yes, we look on HW that can. Your suggestion makes sense,  I will check here
>> if this well addresses the eswitch use case we envision or/what is missing.

> Sounds good let us know. Ben had some comments I need to address as well.

Thinking on this use case a little further, another concern/challenge
would actually be
**creating** these VMDQ interfaces in the guest that has the VF mapped into.

Or.
