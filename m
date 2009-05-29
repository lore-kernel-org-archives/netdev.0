From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/5] netdev: bfin_mac: Blackfin EMAC
	interrupt may not be shared
Date: Fri, 29 May 2009 06:49:42 -0400
Message-ID: <8bd0f97a0905290349p6f52d170i3714cd3ec0c81817@mail.gmail.com>
References: <1243404615-25879-1-git-send-email-vapier@gentoo.org>
	 <1243404615-25879-2-git-send-email-vapier@gentoo.org>
	 <20090529.020122.110502272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.hennerich@analog.com,
	uclinux-dist-devel@blackfin.uclinux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:62055 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754821AbZE2Ktk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 06:49:40 -0400
Received: by yx-out-2324.google.com with SMTP id 3so3288043yxj.1
        for <netdev@vger.kernel.org>; Fri, 29 May 2009 03:49:42 -0700 (PDT)
In-Reply-To: <20090529.020122.110502272.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2009 at 05:01, David Miller wrote:
> From: Mike Frysinger <vapier@gentoo.org>
>> From: Michael Hennerich <michael.hennerich@analog.com>
>>
>> Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
>> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
>> Signed-off-by: Bryan Wu <cooloney@kernel.org>
>
> I'm not applying this.
>
> Either take the time to make this interrupt handler cope with shared
> interrupts (the most preferred) or take the time to write an
> excruciatingly long winded and explicit commit log message explaining
> why that's not possible.
>
> And I want the commit log message path to be as painful as possible so
> that you choose to fix this driver's IRQ handler to behave sanely
> instead. :-)

the hardware has a dedicated internal IRQ line for the Blackfin MAC.
it makes no sense to mark it as shared.  there is nothing it could
possibly be shared with.
-mike
