From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] jhash: Deinline jhash and jhash2
Date: Sun, 19 Jul 2015 11:41:22 -0700 (PDT)
Message-ID: <20150719.114122.199681184036898625.davem@davemloft.net>
References: <1437320160-13290-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, tom@herbertland.com, alexander.h.duyck@redhat.com,
	kadlec@blackhole.kfki.hu, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dvlasenk@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437320160-13290-1-git-send-email-dvlasenk@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denys Vlasenko <dvlasenk@redhat.com>
Date: Sun, 19 Jul 2015 17:36:00 +0200

> This patch deinlines jhash and jhash2.
> 
> It also removes rhashtable_jhash2(key, length, seed)
> because it was merely calling jhash2(key, length, seed).
> 
> With this .config: http://busybox.net/~vda/kernel_config,
> after deinlining these functions have sizes and callsite counts
> as follows:
> 
> jhash: 297 bytes, 111 calls
> jhash2: 205 bytes, 136 calls
> 
> Total size decrease is about 33,000 bytes:
> 
>     text     data      bss       dec     hex filename
> 90663567 17221960 36659200 144544727 89d93d7 vmlinux5
> 90630370 17221864 36659200 144511434 89d11ca vmlinux.after
> 
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>

No performance metrics at all have been provided, so this should
not be applied.
