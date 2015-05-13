From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next v1 4/7] amd-xgbe: Move the PHY support into amd-xgbe
Date: Wed, 13 May 2015 09:01:36 -0500
Message-ID: <55535940.1040300@amd.com>
References: <20150512192229.14091.34354.stgit@tlendack-t1.amdoffice.net>
 <20150512192254.14091.4167.stgit@tlendack-t1.amdoffice.net>
 <55527C8B.1040105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0124.outbound.protection.outlook.com ([207.46.100.124]:11808
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933657AbbEMOBr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 10:01:47 -0400
In-Reply-To: <55527C8B.1040105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/12/2015 05:19 PM, Florian Fainelli wrote:
> On 12/05/15 12:22, Tom Lendacky wrote:
>> The AMD XGBE device is intended to work with a specific integrated PHY
>> and that PHY is not meant to be a standalone PHY for use by other
>> devices. As such this patch removes the phylib driver and implements
>> the PHY support in the amd-xgbe driver (the majority of the logic from
>> the phylib driver is moved into the amd-xgbe driver).
>
> Did not you submit a similar patch a while ago and David asked to keep
> the PHY driver separate? Even though the internal PHY driver might not
> be reusable on another platform, having your Ethernet driver implement a
> PHY library driver seems like a potential layering issue.

I interpreted what David said was that he asked to keep it separate
because I was still using the phy_device structure and calling into the
phy library API. This patch does not use the phy library API. I believe
what I'm doing now is no different than what other NIC drivers do that
manage their PHY(s) on integrated cards (e.g. ixgbe).

Thanks,
Tom

>
