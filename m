From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH RFC net-next] sfc: add support for skb->xmit_more
Date: Wed, 15 Oct 2014 12:05:35 +0100
Message-ID: <543E54FF.1040304@solarflare.com>
References: <543C13AE.80606@solarflare.com> <543C2588.6060604@redhat.com> <alpine.LFD.2.03.1410141933500.26972@solarflare.com> <20141014.171501.448630399243434370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <dborkman@redhat.com>, <nikolay@redhat.com>,
	<netdev@vger.kernel.org>, <sshah@solarflare.com>,
	<jcooper@solarflare.com>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:52252 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751118AbaJOLJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 07:09:39 -0400
In-Reply-To: <20141014.171501.448630399243434370.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/10/14 22:15, David Miller wrote:
> From: Edward Cree <ecree@solarflare.com>
> Date: Tue, 14 Oct 2014 19:41:37 +0100
>
>> Don't ring the doorbell, and don't do PIO.  This will also prevent
>>  TX Push, because there will be more than one buffer waiting when
>>  the doorbell is rung.
>>
>> Signed-off-by: Edward Cree <ecree@solarflare.com>
> This looks good to me, mind if I apply this now?
I'd rather wait until Jon Cooper's had a chance to look at it; he
understands our TX path better than I.

-Edward
