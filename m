From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 1/4] net: percpufy frequently used vars -- add
 percpu_counter_mod_bh
Date: Wed, 8 Mar 2006 15:12:17 -0800
Message-ID: <20060308151217.63cb44c3.akpm@osdl.org>
References: <20060308015808.GA9062@localhost.localdomain>
	<20060308015934.GB9062@localhost.localdomain>
	<20060307181301.4dd6aa96.akpm@osdl.org>
	<20060308202656.GA4493@localhost.localdomain>
	<20060308203642.GZ5410@kvack.org>
	<20060308210726.GD4493@localhost.localdomain>
	<20060308211733.GA5410@kvack.org>
	<20060308222528.GE4493@localhost.localdomain>
	<20060308150609.344c62fa.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751406AbWCHXOQ@vger.kernel.org>
To: kiran@scalex86.org, bcrl@kvack.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org, shai@scalex86.org
In-Reply-To: <20060308150609.344c62fa.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
>
> Once decrapify-asm-generic-localh.patch is merged I think all architectures
>  can and should use asm-generic/local.h.

err, no.  Because that's just atomic_long_t, and that's a locked instruction.

We need to review and fix up those architectures which have implemented the
optimised versions.
