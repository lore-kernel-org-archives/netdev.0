From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: [PATCH net v2 0/2] qlcnic fixes
Date: Fri, 11 Mar 2016 06:40:01 +0000
Message-ID: <BN3PR11MB02730845402BE347A2F978848BB50@BN3PR11MB0273.namprd11.prod.outlook.com>
References: <1457422798-17981-1-git-send-email-rajesh.borundia@qlogic.com>
 <20160310.161635.432267926229064181.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0147.outbound.protection.outlook.com ([65.55.169.147]:15824
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755115AbcCKGzm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 01:55:42 -0500
In-Reply-To: <20160310.161635.432267926229064181.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Friday, March 11, 2016 2:47 AM
>To: Rajesh Borundia <rajesh.borundia@qlogic.com>
>Cc: netdev <netdev@vger.kernel.org>; Dept-GE Linux NIC Dev <Dept-
>GELinuxNICDev@qlogic.com>
>Subject: Re: [PATCH net v2 0/2] qlcnic fixes
>
>From: Rajesh Borundia <rajesh.borundia@qlogic.com>
>Date: Tue, 8 Mar 2016 02:39:56 -0500
>
>> This series adds following fixes.
>>
>> o While processing mailbox if driver gets a spurious mailbox
>>   interrupt it leads into premature completion of a next
>>   mailbox request. Added a guard against this by checking current
>>   state of mailbox and ignored spurious interrupt.
>>   Added a stats counter to record this condition.
>>
>> v2:
>>
>> o Added patch that removes usage of atomic_t as we are not implemeting
>>   atomicity by using atomic_t value.
>>
>> Please apply these fixes to net.
>
>As explained in other list postings, 'net' is basically closed for this release cycle,
>so I applied this series to 'net-next'.
>

Thanks.

>Let me know if you'd like me to therefore queue these changes up for -stable.
>
Please queue the changes for stable.

>Thanks.
