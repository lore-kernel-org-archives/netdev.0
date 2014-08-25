From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [RFC PATCH net-next 3/3] packet: make use of deferred TX queue
 flushing
Date: Mon, 25 Aug 2014 08:40:24 +0200
Message-ID: <53FADA58.4020902@redhat.com>
References: <1408887738-7661-1-git-send-email-dborkman@redhat.com> <1408887738-7661-4-git-send-email-dborkman@redhat.com> <20140824.225741.1546858244063296096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7530 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753254AbaHYGk3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2014 02:40:29 -0400
In-Reply-To: <20140824.225741.1546858244063296096.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2014 07:57 AM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Sun, 24 Aug 2014 15:42:18 +0200
>
>> This adds a first use-case of deferred tail pointer flushing
>> for AF_PACKET's TX_RING in QDISC_BYPASS mode.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>
> If last_queue changes, you'll need to force a flush, does that
> end up happening with your changes here?  I really couldn't
> tell for sure.

Yes indeed, I noticed that later on as well. :)

I will fix that up and resubmit the series, thanks.
