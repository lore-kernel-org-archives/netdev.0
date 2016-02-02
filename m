From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] netfilter: nft_ct: define nft_ct_get_eval_counter() only
 when needed
Date: Tue, 2 Feb 2016 05:19:04 +0100
Message-ID: <20160202041904.GC19789@breakpoint.cc>
References: <1454380257-27195-1-git-send-email-ebiggers3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Biggers <ebiggers3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1454380257-27195-1-git-send-email-ebiggers3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Biggers <ebiggers3@gmail.com> wrote:
> This eliminates an "unused function" compiler warning when
> CONFIG_NF_CONNTRACK_LABELS is not defined.
> 
> Signed-off-by: Eric Biggers <ebiggers3@gmail.com>

The nft_ct_get_eval_counter call should've been unconditional.
The #endif placement is wrong:

https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit?id=efaea94aaf0decd55b15aa7068d4d516a352e56e
