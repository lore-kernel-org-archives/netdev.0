From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [Devel] [PATCH] Virtual ethernet device (tunnel)
Date: Wed, 02 May 2007 14:07:26 +0200
Message-ID: <46387EFE.1080103@fr.ibm.com>
References: <46386DFB.7090109@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	devel@openvz.org
To: Pavel Emelianov <xemul@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:53642 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993063AbXEBMHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 08:07:54 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id l42C7rCF153272
	for <netdev@vger.kernel.org>; Wed, 2 May 2007 12:07:53 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l42C7rIM3940590
	for <netdev@vger.kernel.org>; Wed, 2 May 2007 14:07:53 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l42C7psM019157
	for <netdev@vger.kernel.org>; Wed, 2 May 2007 14:07:52 +0200
In-Reply-To: <46386DFB.7090109@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> Veth stands for Virtual ETHernet. It is a simple tunnel driver
> that works at the link layer and looks like a pair of ethernet
> devices interconnected with each other.
>
> Mainly it allows to communicate between network namespaces but
> it can be used as is as well.
>
> Eric recently sent a similar driver called etun. This
> implementation is closer to the OpenVZ one and it lacks
> some unimportant features of etun driver (like ethtool_ops)
> for simplicity.
>
> The general difference from etun is that a netlink interface
> is used to create and destroy the pairs. The patch for an
> ip utility is also provided.
if etun and veth are similar, why didn't you put the netlink interface 
to the etun driver instead of sending a new driver ?

    -- Daniel
