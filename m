From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net] amd-xgbe: Add the __GFP_NOWARN flag to Rx buffer
 allocation
Date: Mon, 29 Jun 2015 16:47:55 -0500
Message-ID: <5591BD0B.6020802@amd.com>
References: <20150629162212.20833.16427.stgit@tlendack-t1.amdoffice.net>
 <20150629.092722.310092810741640306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0108.outbound.protection.outlook.com ([65.55.169.108]:34112
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752080AbbF2VsB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2015 17:48:01 -0400
In-Reply-To: <20150629.092722.310092810741640306.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/29/2015 11:27 AM, David Miller wrote:
> From: Tom Lendacky <thomas.lendacky@amd.com>
> Date: Mon, 29 Jun 2015 11:22:12 -0500
>
>> When allocating Rx related buffers, alloc_pages is called using an order
>> number that is decreased until successful. A system under stress can
>> experience failures during this allocation process resulting in a warning
>> being issued. This message can be of concern to end users even though the
>> failure is not fatal. Since the failure is not fatal and can occur
>> multiple times, the driver should include the __GFP_NOWARN flag to
>> suppress the warning message from being issued.
>>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>
> Applied, thanks.
>

Hi David,

Can this be queued up for stable 4.0/4.1 (it isn't applicable before
3.19)?

Thanks,
Tom
