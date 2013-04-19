From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] qlcnic: SR-IOV enhancements
Date: Fri, 19 Apr 2013 16:04:16 -0400 (EDT)
Message-ID: <20130419.160416.1495795693055664953.davem@davemloft.net>
References: <1366390875-24570-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47080 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754114Ab3DSUET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:04:19 -0400
In-Reply-To: <1366390875-24570-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Date: Fri, 19 Apr 2013 13:01:07 -0400

> * "qlcnic: Change 82xx adapter VLAN id endian type".
>   - Adapter requires VLAN id in little endian. VLAN id was being
>     converted to __le16 and then passed as a parameter. Pass VLAN id
>     as u16 and then use cpu_to_le16 at appropriate places. It is 
>     appropriate for net-next as SR-IOV patches have a dependency on it.
> * "qlcnic: Fix loopback test for SR-IOV PF".
>   - It is appropriate for net-next as change is needed for SRIOV PF
>     only.
> * Remaining patches add enhancements to SR-IOV functionality like
>   - FLR handling
>   - Adapter reset recovery handling
>   - iproute2 tool support for configuring MAC address, Tx rate and
>     VLAN id.
>   - Mailbox polling support for SR-IOV PF in case mailbox interrupts
>     are disabled.
> 
> Please consider it for net-next.

Series applied, thanks.
