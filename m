From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 4/7] devlink: Add E-Switch inline mode control
Date: Sun, 8 Jan 2017 12:49:20 +0200
Message-ID: <90f3f9f5-beec-be9d-7c92-e6f41f3fd55e@mellanox.com>
References: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
 <1479733561-26601-5-git-send-email-saeedm@mellanox.com>
 <20170108102902.GB1971@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Roi Dayan <roid@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0069.outbound.protection.outlook.com ([104.47.2.69]:40512
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1033438AbdAHKt3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Jan 2017 05:49:29 -0500
In-Reply-To: <20170108102902.GB1971@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/8/2017 12:29 PM, Jiri Pirko wrote:
> Mon, Nov 21, 2016 at 02:05:58PM CET, saeedm@mellanox.com wrote:
>> From: Roi Dayan <roid@mellanox.com>
>>
>> Some HWs need the VF driver to put part of the packet headers on the
>> TX descriptor so the e-switch can do proper matching and steering.
> Could you please elaborate a bit about possible use-cases for different
> modes? Thanks.

As written in the change log, some HW models have this requirement that 
the header set you want eswitch matching on (e.g L2/L3) is present as MD 
on the xmit DMA descriptor.

To address these requirements, following the admin devlink directive the 
FW advertizes that
to the VF, they are doing so in their xmit logic and the host driver 
enforces that the VF has the proper inline mode before we are willing to 
offload eswitch matching rules. If the VF doesn't obey to the 
requirement the packets are dropped by HW.

Or.

Or.
