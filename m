From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 5/5] tipc: clean out all instances of #if 0'd
 unused code
Date: Wed, 13 Oct 2010 13:08:43 -0400
Message-ID: <4CB5E79B.4060507@windriver.com>
References: <1286929558-2954-1-git-send-email-paul.gortmaker@windriver.com> <1286929558-2954-5-git-send-email-paul.gortmaker@windriver.com> <20101013162652.GF31379@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	allan.stephens@windriver.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45309 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796Ab0JMRI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 13:08:57 -0400
In-Reply-To: <20101013162652.GF31379@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-10-13 12:26 PM, Neil Horman wrote:
> On Tue, Oct 12, 2010 at 08:25:58PM -0400, Paul Gortmaker wrote:
>> Remove all instances of legacy, or as yet to be implemented code
>> that is currently living within an #if 0 ... #endif block.
>> In the rare instance that some of it be needed in the future,
>> it can still be dragged out of history, but there is no need
>> for it to sit in mainline.
>>
>> Signed-off-by: Paul Gortmaker<paul.gortmaker@windriver.com>
> Acked-by: Neil Horman<nhorman@tuxdriver.com>
> 

Thanks for all the reviews.  As I'd indicated a while back, I
am by far no TIPC expert, so it may take me a bit to digest
it and rework things on 1 --> 4. That will probably put them
into the "for-38" net-next timeframe, as I'm guessing net-next
that is destined for 2.6.37 will close in a day or two.

This cleanup patch (patch #5) doesn't explicitly depend on
the other 4 bearer related patches, so it can be applied
at whatever time is most convenient for Dave.

Paul.
