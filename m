From: Weongyo Jeong <wjeong@barracuda.com>
Subject: Re: [PATCH] inet: set `error' value not under lock_sock().
Date: Wed, 9 Mar 2016 14:46:04 -0800
Message-ID: <56E0A7AC.70806@barracuda.com>
References: <20160309182217.GA9708@jwg>
 <20160309.153715.770009288781656553.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"weongyo.linux@gmail.com" <weongyo.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bsf01.barracuda.com ([64.235.145.81]:60653 "EHLO
	bsf01.barracuda.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933722AbcCIW54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 17:57:56 -0500
In-Reply-To: <20160309.153715.770009288781656553.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/2016 12:37 PM, David Miller wrote:
> From: Weongyo Jeong <weongyo.linux@gmail.com>
> Date: Wed, 9 Mar 2016 10:22:21 -0800
>
>> A trivial patch to set `error' variable while not holding
>> lock_sock().
>>
>> Signed-off-by: Weongyo Jeong <weongyo.linux@gmail.com>
>
> Deferring the assignment means gcc doesn't have to potentially put it
> on the stack across the lock_sock() call.
>
> You're making the code worse not better, the assignment into a local
> variable is not an expensive operation.
>
> I'm not applying this change, sorry.

No problem.  Thank you for review and opinion.

Regards,
Weongyo Jeong



===========================================================


Considering Office 365?  Barracuda security and storage solutions can help. Learn more about Barracuda solutions for Office 365 at http://barracuda.com/office365.

DISCLAIMER:
This e-mail and any attachments to it contain confidential and proprietary material of Barracuda, its affiliates or agents, and is solely for the use of the intended recipient. Any review, use, disclosure, distribution or copying of this transmittal is prohibited except by or on behalf of the intended recipient. If you have received this transmittal in error, please notify the sender and destroy this e-mail and any attachments and all copies, whether electronic or printed.
