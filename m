From: jamal <hadi@cyberus.ca>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Thu, 14 Jun 2007 07:28:29 -0400
Message-ID: <1181820510.4091.9.camel@localhost>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-acpi@vger.kernel.org, lenb@kernel.org
To: Zhang Rui <rui.zhang@intel.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1181811576.5411.27.camel@localhost.localdomain>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-14-06 at 16:59 +0800, Zhang Rui wrote:
> Hi, Jamal,
> 
> Now the genl utility can find the acpi event genetlink family.
> And a simple user space demo is finished for handling acpi event.
> I really appreciate your help. :)

np.

> I think the patch which exposes ACPI events via netlink is ok.
> But I still have some problems on
> how to listen to specified genetlink family in user space?
> 
> I can get the dynamic id for "acpi_event" genl family.
> But I don't know how to use this to receive messages from
> specified genl family.
> It seems that "#genl ctrl monitor" has something to do with this,
> IMO, rtnl_open_byproto(&rth, nl_mgrp(GENL_ID_CTRL), NETLINK_GENERIC) is
> used to receive messages from the nlctrl(controller) only, but
> unfortunately it never works for me. :(
> 

I dont have much time to look at your code given travel, but did you
try to use your group id instead of the controller's?
i.e:
rtnl_open_byproto(&rth, nl_mgrp(mydiscoveredacpiid), NETLINK_GENERIC)

If this doesnt work, ping me and i will take a look  - just expect some
latency in response.

cheers,
jamal

