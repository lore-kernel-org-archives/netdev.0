From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] percpu: add __percpu sparse annotations to net
Date: Mon, 25 Jan 2010 13:32:47 -0800 (PST)
Message-ID: <20100125.133247.212571046.davem@davemloft.net>
References: <1264432935-10453-1-git-send-email-tj@kernel.org>
	<1264432935-10453-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@infradead.org, viro@zeniv.linux.org.uk,
	netdev@vger.kernel.org, x86@kernel.org, mingo@redhat.com,
	fweisbec@gmail.com, dan.j.williams@intel.com,
	borislav.petkov@amd.com, ying.huang@intel.com, lenb@kernel.org,
	neilb@suse.de, cl@linux-foundation.org, kaber@trash.net,
	acme@ghostprotocols.net, vladislav.yasevich@hp.com
To: tj@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753370Ab0AYVcl@vger.kernel.org>
In-Reply-To: <1264432935-10453-4-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj@kernel.org>
Date: Tue, 26 Jan 2010 00:22:10 +0900

> Add __percpu sparse annotations to net.
> 
> These annotations are to make sparse consider percpu variables to be
> in a different address space and warn if accessed without going
> through percpu accessors.  This patch doesn't affect normal builds.
> 
> The macro and type tricks around snmp stats make things a bit
> interesting.  DEFINE/DECLARE_SNMP_STAT() macros mark the target field
> as __percpu and SNMP_UPD_PO_STATS() macro is updated accordingly.  All
> snmp_mib_*() users which used to cast the argument to (void **) are
> updated to cast it to (void __percpu **).
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Acked-by: David S. Miller <davem@davemloft.net>
