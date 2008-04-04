From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC][PATCH 1/3] Introduce the net_device_ops structure.
Date: Fri, 04 Apr 2008 17:54:55 +0200
Message-ID: <47F64F4F.2020006@trash.net>
References: <47F63681.1030603@openvz.org>	<47F636EC.5070506@openvz.org> <20080404081458.197f58ba@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42011 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736AbYDDPyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 11:54:47 -0400
In-Reply-To: <20080404081458.197f58ba@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Fri, 04 Apr 2008 18:10:52 +0400
> Pavel Emelyanov <xemul@openvz.org> wrote:
> 
>> And fill it with copied from net_device.
>>
>> Also make newly created devices be assigned to the 
>> (currently empty) nd_default_ops.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Thanks, I started this a while back but never got to the bottom.
> Please use const where possible (on dev->nd_ops) and in devices.


It might make sense to keep hard_start_xmit and hard_header
in struct net_device since VLAN and Bonding overload them.
