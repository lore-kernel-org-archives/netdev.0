From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 9/11] net: dst_entry.refcount, use, lastuse to use
 alloc_percpu
Date: Tue, 13 Sep 2005 16:27:48 -0700 (PDT)
Message-ID: <20050913.162748.86496945.davem@davemloft.net>
References: <20050913220737.GA6249@localhost.localdomain>
	<20050913.151216.48124942.davem@davemloft.net>
	<20050913231717.GC6249@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, dipankar@in.ibm.com,
	bharata@in.ibm.com, shai@scalex86.org, rusty@rustcorp.com.au,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932508AbVIMX2K@vger.kernel.org>
To: kiran@scalex86.org
In-Reply-To: <20050913231717.GC6249@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ravikiran G Thirumalai <kiran@scalex86.org>
Date: Tue, 13 Sep 2005 16:17:17 -0700

> But even 1 Million dst cache entries would be 16+4 MB additional for
> a 4 cpu box....is that too much?

Absolutely.

Per-cpu counters are great for things like single instance
statistics et al.  But once you start doing them per-object
that's out of control bloat as far as I'm concerned.
