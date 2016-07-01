From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next V2 08/16] net/devlink: Add E-Switch mode control
Date: Fri, 1 Jul 2016 07:00:16 +0300
Message-ID: <CAJ3xEMiwJM9gpuCWQO_uy7VpLE1AVa1u5tRmfonvUG00BPaaEA@mail.gmail.com>
References: <1467300215-14199-1-git-send-email-saeedm@mellanox.com>
 <1467300215-14199-9-git-send-email-saeedm@mellanox.com> <5775BD44.7080906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:34813 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbcGAEAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 00:00:18 -0400
Received: by mail-oi0-f52.google.com with SMTP id s66so94821259oif.1
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 21:00:17 -0700 (PDT)
In-Reply-To: <5775BD44.7080906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 1, 2016 at 3:45 AM, John Fastabend <john.fastabend@gmail.com> wrote:
> On 16-06-30 08:23 AM, Saeed Mahameed wrote:
>> From: Or Gerlitz <ogerlitz@mellanox.com>
>>
>> Add the commands to set and show the mode of SRIOV E-Switch, two modes
>> are supported:
>>
>> * legacy: operating in the "old" L2 based mode (DMAC --> VF vport)
>>
>> * switchdev: the E-Switch is referred to as whitebox switch configured
>> using standard tools such as tc, bridge, openvswitch etc. To allow
>> working with the tools, for each VF, a VF representor netdevice is
>> created by the E-Switch manager vendor device driver instance (e.g PF).

> OK I can't come up with a better name and Jiri/Or convinced me this
> should work ok so this works for me.

cool.

> One question though going forward. We have devices with multiple
> "switches" in them how does this work in a devlink environment? Do
> we need some way to enumerate the switches and identify them. In
> which case this attribute would be a global setting.

Devices which expose single PCI function for managing multiple switches?

AFAIK the driver for this HW is not upstream yet, there's no real
legacy around them. Since we agree the new mode is the way to go,
global setting should be fine here, I think.

Or.
