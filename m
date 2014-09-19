From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 00/29] Add support for the Intel FM10000 Ethernet
 Switch Host Interface
Date: Fri, 19 Sep 2014 06:57:05 -0400
Message-ID: <541C0C01.6080708@mojatatu.com>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:64078 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbaISK5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 06:57:08 -0400
Received: by mail-ie0-f169.google.com with SMTP id rp18so1181104iec.28
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 03:57:07 -0700 (PDT)
In-Reply-To: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/14 18:35, Alexander Duyck wrote:
> This patch series adds support for the FM10000 Ethernet switch host
> interface.  The Intel FM10000 Ethernet Switch is a 48-port Ethernet switch
> supporting both Ethernet ports and PCI Express host interfaces.  The fm10k
> driver provides support for the host interface portion of the switch, both
> PF and VF.
>
> As the host interfaces are directly connected to the switch this results in
> some significant differences versus a standard network driver.  For example
> there is no PHY or MII on the device.  Since packets are delivered directly
> from the switch to the host interface these are unnecessary.  Otherwise most
> of the functionality is very similar to our other network drivers such as
> ixgbe or igb.  For example we support all the standard network offloads,
> jumbo frames, SR-IOV (64 VFS), PTP, and some VXLAN and NVGRE offloads.
>

First off Kudos to the intel folks. Hopefully this is one of many such
drivers coming - and lets hope this is as landscape-changing as the
e1000 was ;-> Broadcom smell that Tim Horton's coffee.

You described this as a switch but then expose it as a glorified nic.
Assuming more goodstuff(tm) coming?

cheers,
jamal
