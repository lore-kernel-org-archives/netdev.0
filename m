From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next] sfc: add extra RX drop counters for nodesc_trunc
 and noskb_drop
Date: Tue, 15 Jul 2014 13:21:43 +0100
Message-ID: <53C51CD7.3030105@solarflare.com>
References: <alpine.LFD.2.03.1407141534440.19512@solarflare.com> <53C50C35.80200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Dave Miller <davem@davemloft.net>,
	<linux-net-drivers@solarflare.com>
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:30964 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758633AbaGOMVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 08:21:52 -0400
In-Reply-To: <53C50C35.80200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/07/14 12:10, Varka Bhadram wrote:
> On 07/15/2014 04:28 PM, Edward Cree wrote:
>> Added a counter rx_noskb_drop for failure to allocate an skb.
>> Summed the per-channel rx_nodesc_trunc counters earlier so that they can
>>   be included in rx_dropped.
>>
>>
> check patch errors on this patch...  :-)
>
"Macros with complex values should be enclosed in parenthesis" is a
false positive - the macro is for a structure initialiser.
The long lines are both justifiable and only slightly over 80 columns.
So checkpatch is just being fascist as usual ;)

-Edward
