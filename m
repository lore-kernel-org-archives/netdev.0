From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 06/10] net/mlx4: Add mlx4_bitmap zone allocator
Date: Tue, 9 Dec 2014 22:29:38 +0200
Message-ID: <CAJ3xEMgqBy1TuSSPckTRbFwmHFi-3v7JbGWed4ckA_9nbF3hAg@mail.gmail.com>
References: <1417698835-11050-1-git-send-email-ogerlitz@mellanox.com>
	<1417698835-11050-7-git-send-email-ogerlitz@mellanox.com>
	<20141209.144210.1356501987854068706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	"talal@mellanox.com" <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:45147 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbaLIU3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 15:29:39 -0500
Received: by mail-ob0-f169.google.com with SMTP id vb8so1112289obc.14
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 12:29:38 -0800 (PST)
In-Reply-To: <20141209.144210.1356501987854068706.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 9, 2014 at 9:42 PM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Thu,  4 Dec 2014 15:13:51 +0200
>
>> +static u32 mlx4_bitmap_max(struct mlx4_bitmap *bitmap)
>> +{
>> +     return bitmap->max;
>> +}
>> +
>> +static u32 mlx4_bitmap_effective_len(struct mlx4_bitmap *bitmap)
>> +{
>> +     return bitmap->effective_len;
>> +}
>
> Using functions for just accessing structure members is excessive, please
> just open code this.

sure, we will fix that, I see now that we have two fixes to apply, so
will respin the series and send it to you tomorrow.
