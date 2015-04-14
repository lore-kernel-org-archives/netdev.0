From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next V1 00/11] net/mlx5: ConnectX-4 100G Ethernet driver
Date: Tue, 14 Apr 2015 10:05:59 +0300
Message-ID: <CAPcc5PiXo0yiiM_Y3Cwr8z8LXojZ77m5yMa5Gde9-SifMCF0CQ@mail.gmail.com>
References: <1428925501-2373-1-git-send-email-amirv@mellanox.com>
	<20150413.221522.162480193486167425.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>, netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, talal@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:36316 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbbDNHGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 03:06:00 -0400
Received: by lbbqq2 with SMTP id qq2so761063lbb.3
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 00:05:59 -0700 (PDT)
In-Reply-To: <20150413.221522.162480193486167425.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 14, 2015 at 5:15 AM, David Miller <davem@davemloft.net> wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Mon, 13 Apr 2015 14:44:50 +0300
>
>> - Removed V0 Patch 1/11 ("net/mlx5_core: Virtually extend work/completion queue
>>   buffers by one page") due to misuse of DMA API. Thanks Dave.
>
> I don't know how stupid you think I am....
Hi,

It is our interest to fix this bug here and in the existing code. We
don't like either, that our driver is mis-using the DMA API and that
it is broken on some arch's.

>
> You may have removed the patch that did the refactoring, but the
> completely broken code misusing the DMA API is still there in this
> driver.
>
> I said I want you to fix this fundamental problem with your driver
> before making major changes like this series to it.
>
> And I really meant it.
>
> Don't try to side step the issue in the way that you did here.
It is just a misunderstanding of your sentence: "I'm sorry but I'm
going to require that you fix this mis-use of the DMA API first.". I
thought that it should be fixed in this patchset first....

We were working on a fix to the existing code that is based on vmap,
and I planned to send it in a separate patch later on.
I will soon send V2 with a patch to remove the vmap()  from current
code. It might be problematic to some Infiniband users of mlx5_core,
that will now need to allocate big continuous buffers, I will send the
fix to that in a separate patch in few weeks.

Thanks,
Amir
>
> Thanks.
