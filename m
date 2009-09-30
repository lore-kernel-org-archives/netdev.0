From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH,TRIVIAL] Fix csum_ipv6_magic asm memory clobber
Date: Wed, 30 Sep 2009 16:22:33 -0700 (PDT)
Message-ID: <20090930.162233.208543104.davem@davemloft.net>
References: <4AC3DF7B.5060407@zytor.com>
	<20090930230138.GZ6451@const.famille.thibault.fr>
	<20090930161939.8c6d140a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel.thibault@ens-lyon.org, hpa@zytor.com,
	linux-kernel@vger.kernel.org, mingo@elte.hu, tglx@linutronix.de,
	andi@firstfloor.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754818AbZI3XWP@vger.kernel.org>
In-Reply-To: <20090930161939.8c6d140a.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 30 Sep 2009 16:19:39 -0700

> From: Samuel Thibault <samuel.thibault@ens-lyon.org>
> 
> Just like ip_fast_csum, the assembly snippet in csum_ipv6_magic needs a
> memory clobber, as it is only passed the address of the buffer, not a
> memory reference to the buffer itself.
> 
> This caused failures in Hurd's pfinetv4 when we tried to compile it with
> gcc-4.3 (bogus checksums).
> 
> Signed-off-by: Samuel Thibault <samuel.thibault@ens-lyon.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

I'm happy to see this go in via the x86 tree, and thus:

Acked-by: David S. Miller <davem@davemloft.net>
