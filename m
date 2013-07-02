From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH for-next 0/8] Add Mellanox mlx5 driver for Connect-IB devices
Date: Wed, 3 Jul 2013 00:02:30 +0300
Message-ID: <CAJZOPZLQWZ69sA6YjdVXGVYoRuORnGxG7FBwwh+pQPn87KZCqQ@mail.gmail.com>
References: <1371384149-24558-1-git-send-email-eli@dev.mellanox.co.il>
	<CAJZOPZ+NQa3CWnw3rZQh2UuwdrNhiwtVSyuk9D9YtwfQQ9e1XA@mail.gmail.com>
	<CAJZOPZKLb9k1xXkTnrtzYKpwrSJDQgBpONUVCp3et36JeaEi-Q@mail.gmail.com>
	<CAL1RGDX5mHj5oVqFhQ4Ssr25jpL4rV2Tv=zXvLOZfwupJ0gqJw@mail.gmail.com>
	<1372701839.2481.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Roland Dreier <roland@kernel.org>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>, Eli Cohen <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f52.google.com ([209.85.216.52]:40841 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754883Ab3GBVCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 17:02:31 -0400
Received: by mail-qa0-f52.google.com with SMTP id bv4so3128058qab.18
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 14:02:30 -0700 (PDT)
In-Reply-To: <1372701839.2481.3.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 1, 2013 at 9:03 PM, Joe Perches <joe@perches.com> wrote:
> On Mon, 2013-07-01 at 10:49 -0700, Roland Dreier wrote:

[...]
>> +struct mlx5_cmd {
>> ...
>> +    struct mlx5_cmd_stats    stats[0x80a];
>> the 0x80a magic number really needs to have a name.

> And that's a pretty big struct too. 2058 array entries. ~100kb
> Does it really need to be that big?

Indeed a bit of biggish, but note there's just one instance of this
arrary per HCA port. For now we will leave this size but make it less
obscure, will be MLX5_CMD_OP_LAST
