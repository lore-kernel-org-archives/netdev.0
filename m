From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/2] The new jhash implementation
Date: Sat, 27 Nov 2010 14:01:22 +1030
Message-ID: <201011271401.22773.rusty@rustcorp.com.au>
References: <1290690908-794-1-git-send-email-kadlec@blackhole.kfki.hu> <1290690908-794-2-git-send-email-kadlec@blackhole.kfki.hu> <1290690908-794-3-git-send-email-kadlec@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290690908-794-3-git-send-email-kadlec@blackhole.kfki.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 25 Nov 2010 11:45:08 pm Jozsef Kadlecsik wrote:
> The current jhash.h implements the lookup2() hash function by Bob Jenkins.
> However, lookup2() is outdated as Bob wrote a new hash function called
> lookup3(). The new hash function

Oops, we discussed this ages ago, looks like it fell through the cracks.

Thanks Jozsef!

> +extern u32 jhash(const void *key, u32 length, u32 initval);
> +extern u32 jhash2(const u32 *k, u32 length, u32 initval);
> +extern u32 jhash_3words(u32 a, u32 b, u32 c, u32 initval);

This last one can be marked __attribute__((const)) for a little
extra compiler help, too.

Cheers,
Rusty.
