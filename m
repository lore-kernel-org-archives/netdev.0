From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] ip6: Transmit tunneling fixes
Date: Tue, 10 May 2016 00:39:42 -0400 (EDT)
Message-ID: <20160510.003942.2286178035902304419.davem@davemloft.net>
References: <1462839132-980991-1-git-send-email-tom@herbertland.com>
	<CAKgT0Ue_D0_nGuYQnrYfXBDdKb+ieUhZKcfnz_QxhN61mvReBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org, kernel-team@fb.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36875 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbcEJEjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 00:39:47 -0400
In-Reply-To: <CAKgT0Ue_D0_nGuYQnrYfXBDdKb+ieUhZKcfnz_QxhN61mvReBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 9 May 2016 20:30:46 -0700

> On Mon, May 9, 2016 at 5:12 PM, Tom Herbert <tom@herbertland.com> wrote:
>> Several fixes suggested by Alexander.
>>
>> Tested: Running netperf TCP_STREAM with gretap and keyid configured.
>> Visually verified that MTU is correctly being set. Did not test HW
>> offload (Alexander plese try)
> 
> This appears to have fixed the issues I saw.  I can confirm the MTU is
> the same value that it was before the regression and I am able to
> send/receive at around 17Gb/s.
> 
> Tested-by: Alexander Duyck <aduyck@mirantis.com>

Series applied, thanks everyone.
