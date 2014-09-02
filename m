From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next v1 0/3] amd-xgbe: AMD XGBE driver updates 2014-08-29
Date: Tue, 2 Sep 2014 14:55:49 -0500
Message-ID: <540620C5.2070906@amd.com>
References: <20140829152148.13783.23789.stgit@tlendack-t1.amdoffice.net>
 <20140901.203152.216310411574954349.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0141.outbound.protection.outlook.com ([207.46.163.141]:37641
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750954AbaIBT4A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 15:56:00 -0400
In-Reply-To: <20140901.203152.216310411574954349.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2014 10:31 PM, David Miller wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> Date: Fri, 29 Aug 2014 10:21:48 -0500
>
>> The amd-xgbe-phy phylib driver support is integral to the amd-xgbe
>> driver and isn't meant to be used by other devices.  For this reason
>> it is being removed from the driver/net/phy directory and integrated
>> into the amd-xgbe driver.
>
> I see no real reason to do this.
>
> Keeping it in the phylib layer forces you to deal with the abstractions
> and therefore keeps you from bypassing the phylib API and performing
> layer violations.
>
> Please just keep the PHY driver where it is and add your new features
> there.

Ok, understood.  I'll drop this patch series.  Any future changes or
enhancements will apply against the established file locations.

Thanks,
Tom

>
> Thanks.
>
