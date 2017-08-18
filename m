From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next v1 05/14] amd-xgbe: Add additional debugfs
 support
Date: Fri, 18 Aug 2017 07:58:03 -0500
Message-ID: <624ab709-c609-1f8d-b635-c824dac5c693@amd.com>
References: <20170818000201.10005.36182.stgit@tlendack-t1.amdoffice.net>
 <20170818000250.10005.87855.stgit@tlendack-t1.amdoffice.net>
 <20170818003057.GA11030@lunn.ch>
 <20170817.220203.1607309698344574831.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0046.outbound.protection.outlook.com ([104.47.42.46]:21289
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751036AbdHRM6I (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 08:58:08 -0400
In-Reply-To: <20170817.220203.1607309698344574831.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/2017 12:02 AM, David Miller wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Fri, 18 Aug 2017 02:30:57 +0200
> 
>> On Thu, Aug 17, 2017 at 07:02:50PM -0500, Tom Lendacky wrote:
>>> Add additional debugfs support for reading / writing registers of any
>>> attached external phy devices as well as the SFP eeprom data.
>>
>> Hi Tom
>>
>> What is wrong with using the standard APIs for this?
>>
>> ethtool --moduile-info
>>
>> ioctls SIOCGMIIREG and SIOCSMIIREG.
> 
> Yeah debugfs is a horrible choice for this.
> 
> debugfs in general should be strongly avoided.  We have rich eneough
> facilities to export just about anything that is actually appropriate
> and useful, and where we do not existing facilities should be extended
> as needed rather than ignored.

I was intending this to be purely debugging and that's why I chose
debugfs as opposed to ethtool.  I can switch over to using ethtool
though.  I'll resubmit the series without this patch and look at
moving to this to ethtool as a separate patch later.

Thanks,
Tom

> 
