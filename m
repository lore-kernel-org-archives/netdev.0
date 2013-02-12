From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH net-next 1/5] gianfar: Cleanup device refs in gfar_private
Date: Tue, 12 Feb 2013 19:14:11 +0200
Message-ID: <511A7863.8000901@freescale.com>
References: <1360673237-349-1-git-send-email-claudiu.manoil@freescale.com> <511A57AA.8070004@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:40442
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932336Ab3BLROY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 12:14:24 -0500
In-Reply-To: <511A57AA.8070004@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/12/2013 4:54 PM, Paul Gortmaker wrote:
> On 13-02-12 07:47 AM, Claudiu Manoil wrote:
>> * remove unused device_node pointer
>> * remove duplicate SET_NETDEV_DEV()
>> * use device pointer (dev) to simplify the code and to
>>    avoid double indirections (esp. on the "fast path")
>
> Ideally, when you find yourself making a list within the longlog,
> that is a hint that you might want to start making it into
> multiple commits, for ease of review.  Granted #1 and #2 are
> trivial, but #3 probably could be a separate commit.  Did you
> see any change in the object size or the disassembly when
> making change #3?
>
> P.

I didn't inspect the assembly code yet, but this should definitely
generate better, faster code. I don't see why it wouldn't...

Thanks,
Claudiu
