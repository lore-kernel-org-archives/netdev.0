From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH for-next V1 1/2] net/mlx5: Fix mlx5 ifc cmd_hca_cap bad offsets
Date: Thu, 14 Apr 2016 00:54:02 +0300
Message-ID: <CALzJLG96VWEk_9NC9UTtYG7OMW8zHboGxJyrMEfQCT34rFFT5g@mail.gmail.com>
References: <1460563864-22931-1-git-send-email-saeedm@mellanox.com>
 <1460563864-22931-2-git-send-email-saeedm@mellanox.com> <20160413174820.GC28411@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Doug Ledford <dledford@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-rdma@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:34193 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbcDMVyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 17:54:22 -0400
Received: by mail-yw0-f181.google.com with SMTP id d68so85339037ywe.1
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 14:54:22 -0700 (PDT)
In-Reply-To: <20160413174820.GC28411@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2016 at 8:48 PM, Jason Gunthorpe
<jgunthorpe@obsidianresearch.com> wrote:
> On Wed, Apr 13, 2016 at 07:11:03PM +0300, Saeed Mahameed wrote:
>
>> Fixes: b0844444590e ("net/mlx5_core: Introduce access function to read internal timer ")
>> Fixes: b4ff3a36d3e4 ("net/mlx5: Use offset based reserved field names in the IFC header file")
>
> Are you sure those are right? b doesn't have the
> reserved_at names.
>

Yes, as stated in the commit message, change b0844444590e replaced two
reserved fields with 3 fields with a different size than the original
two, which broke all the offsets of the fields that came after.

>
> You know, the reserved_XXX just need to have unique unchanging
> numbers, it doesn't matter what the numbers are - but you have to stop
> changing them :( That is the key to avoiding conflicts when
> backporting/merging/etc.
>
> I guess the big rename has already landed, but simply stopping the
> practice of renumbing the reserved fields would have been enough.
>

This was a mistake which had to be fixed, the offset numbering was
wrong from day one of introducing those offsets, I prefer to do it
now, once and forever.

But i totally agree, we will do our best to keep this file clean as
much as possible.
Thanks for your concern.

Saeed.
