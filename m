From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [RFC] xgbe: constify get_netdev_ops and get_ethtool_ops
Date: Wed, 31 Aug 2016 19:50:32 -0500
Message-ID: <b4dedd72-8c15-2873-e471-8cb5a5485ded@amd.com>
References: <1472628648-3603-1-git-send-email-Julia.Lawall@lip6.fr>
 <20160831085736.29fc6512@xeon-e3>
 <20160831.141750.55012883444641424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <Julia.Lawall@lip6.fr>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0042.outbound.protection.outlook.com ([104.47.41.42]:8256
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753869AbcIADYD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 Aug 2016 23:24:03 -0400
In-Reply-To: <20160831.141750.55012883444641424.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2016 04:17 PM, David Miller wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Wed, 31 Aug 2016 08:57:36 -0700
> 
>> Casting away const is bad practice. Since this is ARM specific driver
>> don't have hardware actually test this.
>>
>> Having getter functions for ops is really unnecessary code bloat, but
>> not going to touch that.
>>
>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> I'll just apply this, let's see what happens.

I should be able to test this in the next few days. I don't expect there
to be an issue. I'll let you know what I find.

Thanks,
Tom

> 
