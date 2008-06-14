From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net: Fix test for VLAN TX checksum offload capability
Date: Sat, 14 Jun 2008 10:09:08 +0200
Message-ID: <48537CA4.7040005@trash.net>
References: <20080613223815.GD11300@solarflare.com> <20080613154307.4a6f721f@extreme> <20080613231139.GE11300@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64172 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753418AbYFNIJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 04:09:12 -0400
In-Reply-To: <20080613231139.GE11300@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Stephen Hemminger wrote:
>> On Fri, 13 Jun 2008 23:38:16 +0100
>> Ben Hutchings <bhutchings@solarflare.com> wrote:
>>
>>> Selected device feature bits can be propagated to VLAN devices, so we
>>> can make use of TX checksum offload and TSO on VLAN-tagged packets.
>>> However, if the physical device does not do VLAN tag insertion or
>>> generic checksum offload then the test for TX checksum offload in
>>> dev_queue_xmit() will see a protocol of htons(ETH_P_8021Q) and yield
>>> false.
>> Are you sure that some hardware isn't broken and can do vlan tag
>> insertion or checksumming but not both?
> 
> The second test uses dev->features & dev->vlan_features, so this should
> be handled correctly, unless I'm missing some subtlety.

It looks fine to me.
