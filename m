From: David Miller <davem@davemloft.net>
Subject: Re: net-next: 2.6.34-rc1 regression: panic when running diagnostic
 on interface with IPv6
Date: Mon, 05 Apr 2010 16:53:17 -0700 (PDT)
Message-ID: <20100405.165317.89399272.davem@davemloft.net>
References: <EA929A9653AAE14F841771FB1DE5A1365FE4E2E26C@rrsmsx501.amr.corp.intel.com>
	<20100405.161221.159637463.davem@davemloft.net>
	<EA929A9653AAE14F841771FB1DE5A1365FE4E2E334@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: emil.s.tantilov@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44658
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756975Ab0DEXxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 19:53:15 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FE4E2E334@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Date: Mon, 5 Apr 2010 17:50:38 -0600

> David Miller wrote:
>> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
>> Date: Mon, 5 Apr 2010 17:03:56 -0600
>> 
>>> David Miller wrote:
>>>> From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
>>>> Date: Tue, 23 Mar 2010 12:28:08 -0600
>>>> 
>>>>> Bisecting points to this patch:
>>>>> http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=84e8b803f1e16f3a2b8b80f80a63fa2f2f8a9be6
>>>>> 
>>>>> And I confirmed that the issue goes away after reverting it.
>>>>> 
>>>>> Steps to reproduce:
>>>>> 1. Load the driver and configure IPv6 address.
>>>>> 2. Run ethtool diag:
>>>>> ethtool -t eth0
>>>>> 
>>>>> 3. If this doesn't brake it try again, or just do ifdown/up. Other
>>>>> operations on the interface will eventually panic the system:
>>>> 
>>>> Stephen please fix this, thanks.
>>> 
>>> Just FYI - I still see this issue with latest pull from net-2.6.
>> 
>> It's net-next-2.6 that introduced the problem and has the follow-on
>> fixes, not net-2.6
> 
> Same in net-next:

Ok, Stephen please look into this, we've had this regression
for almost two weeks now.
