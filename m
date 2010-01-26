From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 7/8] percpu: add __percpu sparse annotations to	hw_breakpoint
Date: Tue, 26 Jan 2010 11:47:46 +0900
Message-ID: <4B5E57D2.8030109@kernel.org>
References: <1264432935-10453-8-git-send-email-tj@kernel.org> <20100126001901.GI5087@nowhere> <4B5E3BED.6030705@kernel.org> <20100126010239.GK5087@nowhere> <4B5E4308.8020105@kernel.org> <20100126020113.GM5087@nowhere> <4B5E4FE7.30700@kernel.org> <20100126021846.GO5087@nowhere> <20100126022211.GP5087@nowhere> <4B5E54C0.2040709@kernel.org> <20100126023542.GQ5087@nowhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@infradead.org, viro@zeniv.linux.org.uk,
	davem@davemloft.net, netdev@vger.kernel.org, x86@kernel.org,
	mingo@redhat.com, dan.j.williams@intel.com,
	borislav.petkov@amd.com, ying.huang@intel.com, lenb@kernel.org,
	neilb@suse.de, cl@linux-foundation.org
To: Frederic Weisbecker <fweisbec@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753575Ab0AZCnL@vger.kernel.org>
In-Reply-To: <20100126023542.GQ5087@nowhere>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/26/2010 11:35 AM, Frederic Weisbecker wrote:
> No guarantee that will build. I should pull your tree and install
> sparse (yeah, shame on me, I've never installed it).

Nope, it doesn't.  Please pull from the following tree to receive the
whole thing.  The definitions in question are in
include/asm-generic/percpu.h.

 git://git.kernel.org/pub/scm/linux/kernel/git/tj/percpu.git percpu-sparse-review

After installing sparse,

 make C=2 arch/x86/kernel/cpu/common.o

should be enough.

Thanks.

-- 
tejun
