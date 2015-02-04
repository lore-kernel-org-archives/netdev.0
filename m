From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] net: bluetooth: hci_sock: Use 'const void *' instead
 of 'void *' for 2nd parameter of hci_test_bit()
Date: Wed, 04 Feb 2015 23:13:28 +0300
Message-ID: <54D27D68.7040501@cogentembedded.com>
References: <54CFE8BE.5030700@sunrus.com.cn> <063D6719AE5E284EB5DD2968C1650D6D1CADA5E1@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"linux-bluetooth@vger.kernel.org" <linux-bluetooth@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	'Chen Gang S' <gang.chen@sunrus.com.cn>,
	"marcel@holtmann.org" <marcel@holtmann.org>,
	"gustavo@padovan.org" <gustavo@padovan.org>,
	"johan.hedberg@gmail.com" <johan.hedberg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:47109 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934021AbbBDUNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 15:13:33 -0500
Received: by mail-lb0-f170.google.com with SMTP id w7so3560468lbi.1
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 12:13:32 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CADA5E1@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02/04/2015 02:59 PM, David Laight wrote:

>> -static inline int hci_test_bit(int nr, void *addr)
>> +static inline int hci_test_bit(int nr, const void *addr)
>>   {
>>   	return *((__u32 *) addr + (nr >> 5)) & ((__u32) 1 << (nr & 31));
>>   }

> Is there a 'standard' function lurking that will do the above.
> On x86 the cpus 'bit test' instruction will handle bit numbers
> greater than the word size - so it can be a single instruction.

    Of course, there's test_bit().

> 	David

WBR, Sergei
