From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: avoid leaking memory on bnx2x_init_one()
 failures
Date: Tue, 31 May 2016 14:11:11 -0700 (PDT)
Message-ID: <20160531.141111.2242150565551090751.davem@davemloft.net>
References: <1464613254-13640-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ariel.elior@qlogic.com
To: vkuznets@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464613254-13640-1-git-send-email-vkuznets@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vitaly Kuznetsov <vkuznets@redhat.com>
Date: Mon, 30 May 2016 15:00:54 +0200

> bnx2x_init_bp() allocates memory with bnx2x_alloc_mem_bp() so if we
> fail later in bnx2x_init_one() we need to free this memory
> with bnx2x_free_mem_bp() to avoid leakages. E.g. I'm observing memory
> leaks reported by kmemleak when a failure (unrelated) happens in
> bnx2x_vfpf_acquire().
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

Applied.
