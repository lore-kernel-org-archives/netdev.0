From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: [PATCH] forcedeth: updated phy errata
Date: Fri, 04 Sep 2009 09:57:59 -0400
Message-ID: <4AA11CE7.7050400@nvidia.com>
References: <4A9C57F5.10800@nvidia.com> <20090902.232201.248326790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "manfred@colorfullife.com" <manfred@colorfullife.com>,
	"akpm@osdl.org" <akpm@osdl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:17462 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757198AbZIDTZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 15:25:07 -0400
In-Reply-To: <20090902.232201.248326790.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Miller wrote:
> From: Ayaz Abdulla <aabdulla@nvidia.com>
> Date: Mon, 31 Aug 2009 19:08:37 -0400
> 
> 
>>This patch updates the special programming (and/or errata) needed in
>>order to setup the phy for various vendor models.
>>
>>The new models include:
>>Marvell E1116
>>Marvell E1111
>>Marvell E1011
>>Marvell E3016
>>Broadcom 9507
>>Broadcom AC131
>>Broadcom 50610
>>
>>Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> 
> 
> Please document what these individual bits mean which you
> are clearing, by using an individual define for each register
> bit to describe it's purpose, and then define the mask as
> a concatenation of these bits.
> 
> Having an opaque bitmask is not how to do this.

Unfortunately, the phy vendors don't want us exposing the meaning of 
their non-standard bits.


> 
> Thanks.
