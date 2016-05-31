From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net] bnx2x: avoid leaking memory on bnx2x_init_one()
 failures
Date: Tue, 31 May 2016 06:46:59 +0000
Message-ID: <CO2PR11MB00881722285408A691C4D92997460@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1464613254-13640-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Vitaly Kuznetsov <vkuznets@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464613254-13640-1-git-send-email-vkuznets@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> bnx2x_init_bp() allocates memory with bnx2x_alloc_mem_bp() so if we fail later
> in bnx2x_init_one() we need to free this memory with bnx2x_free_mem_bp() to
> avoid leakages. E.g. I'm observing memory leaks reported by kmemleak when a
> failure (unrelated) happens in bnx2x_vfpf_acquire().
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>

Thanks.

Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
