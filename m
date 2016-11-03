From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next v1 02/21] amd-xgbe: Prepare for priority-based
 FIFO allocation
Date: Thu, 3 Nov 2016 09:50:38 -0500
Message-ID: <e318ab26-51ea-1d79-8b47-12b452ebb05a@amd.com>
References: <20161103132744.3437.27332.stgit@tlendack-t1.amdoffice.net>
 <20161103132804.3437.40002.stgit@tlendack-t1.amdoffice.net>
 <BL2PR07MB23065CE0C48D76AB76E78ACF8DA30@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0064.outbound.protection.outlook.com ([104.47.33.64]:17795
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1757937AbcKCOuw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 10:50:52 -0400
In-Reply-To: <BL2PR07MB23065CE0C48D76AB76E78ACF8DA30@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/2016 08:51 AM, Mintz, Yuval wrote:
>> +static void xgbe_calculate_equal_fifo(unsigned int fifo_size,
>> +				      unsigned int queue_count,
>> +				      unsigned int *fifo)
>> +{
> ...
>> +
>> +	return;
>>  }
> 
> No need for explicit return.
> 

Ok, if there's feedback that requires a v2 I'll remove the return,
otherwise I plan to submit a checkpatch cleanup series as a follow-up
to fix some of the new warnings issued by the newer version of
checkpatch.

Thanks,
Tom
