From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rhashtable: Drop gfp_flags arg in
 insert/remove functions
Date: Thu, 13 Nov 2014 15:18:53 -0500 (EST)
Message-ID: <20141113.151853.1944374659110428712.davem@davemloft.net>
References: <17c3262027e643a0826c6ac5dd2d14cda0822a0b.1415879747.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, eric.dumazet@gmail.com
To: tgraf@suug.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <17c3262027e643a0826c6ac5dd2d14cda0822a0b.1415879747.git.tgraf@suug.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 13 Nov 2014 13:45:46 +0100

> Reallocation is only required for shrinking and expanding and both rely
> on a mutex for synchronization and callers of rhashtable_init() are in
> non atomic context. Therefore, no reason to continue passing allocation
> hints through the API.
> 
> Instead, use GFP_KERNEL and add __GFP_NOWARN | __GFP_NORETRY to allow
> for silent fall back to vzalloc() without the OOM killer jumping in as
> pointed out by Eric Dumazet and Eric W. Biederman.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
