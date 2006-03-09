From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 1/4] net: percpufy frequently used vars -- add percpu_counter_mod_bh
Date: Thu, 09 Mar 2006 19:14:26 +1100
Message-ID: <440FE3E2.1060307@yahoo.com.au>
References: <20060307181301.4dd6aa96.akpm@osdl.org> <20060308202656.GA4493@localhost.localdomain> <20060308203642.GZ5410@kvack.org> <20060308210726.GD4493@localhost.localdomain> <20060308211733.GA5410@kvack.org> <20060308222528.GE4493@localhost.localdomain> <20060308224140.GC5410@kvack.org> <20060308154321.0e779111.akpm@osdl.org> <20060309001803.GF4493@localhost.localdomain> <20060308163258.36f3bd79.akpm@osdl.org> <20060309080651.GA3599@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, bcrl@kvack.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, shai@scalex86.org, Andi Kleen <ak@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750857AbWCIIPT@vger.kernel.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
In-Reply-To: <20060309080651.GA3599@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ravikiran G Thirumalai wrote:

> Here's a patch making x86_64 local_t to 64 bits like other 64 bit arches.
> This keeps local_t unsigned long.  (We can change it to signed value 
> along with other arches later in one go I guess) 
> 

Why not just keep naming and structure of interfaces consistent with
atomic_t?

That would be signed and 32-bit. You then also have a local64_t.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 
