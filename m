From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next 06/10] amd-xgbe: Set DMA mask based on hardware
 register value
Date: Thu, 19 Mar 2015 13:53:26 -0500
Message-ID: <550B1B26.8000204@amd.com>
References: <20150319171301.26446.71081.stgit@tlendack-t1.amdoffice.net>
	<063D6719AE5E284EB5DD2968C1650D6D1CB046B5@AcuExch.aculab.com>
	<550B09F5.8000707@amd.com>
 <20150319.144324.217714702082923027.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <David.Laight@ACULAB.COM>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0103.outbound.protection.outlook.com ([157.56.111.103]:29239
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751115AbbCSSxb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 14:53:31 -0400
In-Reply-To: <20150319.144324.217714702082923027.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/19/2015 01:43 PM, David Miller wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> Date: Thu, 19 Mar 2015 12:40:05 -0500
>
>> Except this version of the hardware can't return a 3
>
> Yep, I've never _ever_ seen HW return garbage in a register.
>
> Nope.
>
> No reason to every program defensively for that.

Point taken :-).  I'll add a default to 32 bit and submit v2.

Thanks,
Tom

>
