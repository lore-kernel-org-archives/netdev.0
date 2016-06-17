From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH 1/2] mlx5: only register devlink when ethernet is available
Date: Fri, 17 Jun 2016 17:50:14 +0300
Message-ID: <CALzJLG8BEivMg4h+=FcQ_7QFrZTRhRNsPgEH68WPKfmkguvNqA@mail.gmail.com>
References: <20160615152816.2800830-1-arnd@arndb.de> <CALzJLG_CkvbrCehMjMht5KfMK6r-FbvPzzYUEhpA40YHymsh+Q@mail.gmail.com>
 <6330398.ySWGKSmLdn@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Eli Cohen <eli@mellanox.com>, Majd Dibbiny <majd@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:33350 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbcFQOue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 10:50:34 -0400
Received: by mail-yw0-f194.google.com with SMTP id d137so3183893ywe.0
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 07:50:34 -0700 (PDT)
In-Reply-To: <6330398.ySWGKSmLdn@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2016 at 11:50 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Wednesday, June 15, 2016 7:04:54 PM CEST Saeed Mahameed wrote:
> Ok, I see. It would be nice if the process had a way to avoid build regressions
> in linux-next, in particular if you already have a fix by the time a patch
> that introduces a problem gets added.
>

The reason we added this tree is to get 0-day testing but currently it
makes some unwanted noise
so we will remove it until we figure it out.

>
> Can you check if the fix for the second problem correctly removes the
> unnecessary 64-bit division (as opposed to adding a call to div_s64()
> or do_div()), and if it removes all traces of 'struct timespec' again?
>

Yes, same thing, already fixed, will reply to that thread.
