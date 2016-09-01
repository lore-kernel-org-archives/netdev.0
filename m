From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [RFC] xgbe: constify get_netdev_ops and get_ethtool_ops
Date: Thu, 1 Sep 2016 12:45:13 -0500
Message-ID: <feff89c8-d08b-e4ab-f260-ed274910c6d9@amd.com>
References: <1472628648-3603-1-git-send-email-Julia.Lawall@lip6.fr>
 <20160831085736.29fc6512@xeon-e3>
 <20160831.141750.55012883444641424.davem@davemloft.net>
 <b4dedd72-8c15-2873-e471-8cb5a5485ded@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <Julia.Lawall@lip6.fr>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0075.outbound.protection.outlook.com ([104.47.36.75]:55616
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751399AbcIAWUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 18:20:16 -0400
In-Reply-To: <b4dedd72-8c15-2873-e471-8cb5a5485ded@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2016 07:50 PM, Tom Lendacky wrote:
> On 08/31/2016 04:17 PM, David Miller wrote:
>> From: Stephen Hemminger <stephen@networkplumber.org>
>> Date: Wed, 31 Aug 2016 08:57:36 -0700
>>
>>> Casting away const is bad practice. Since this is ARM specific driver
>>> don't have hardware actually test this.
>>>
>>> Having getter functions for ops is really unnecessary code bloat, but
>>> not going to touch that.
>>>
>>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>>
>> I'll just apply this, let's see what happens.
> 
> I should be able to test this in the next few days. I don't expect there
> to be an issue. I'll let you know what I find.

No issues found in build and test. For what it's worth since the patch
is already applied:

Tested-by: Tom Lendacky <thomas.lendacky@amd.com>

> 
> Thanks,
> Tom
> 
>>
