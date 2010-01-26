From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 7/8] percpu: add __percpu sparse annotations to	hw_breakpoint
Date: Tue, 26 Jan 2010 11:10:56 +0900
Message-ID: <4B5E4F30.60600@kernel.org>
References: <1264432935-10453-1-git-send-email-tj@kernel.org> <1264432935-10453-8-git-send-email-tj@kernel.org> <20100126001901.GI5087@nowhere> <4B5E401D.2020809@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Frederic Weisbecker <fweisbec@gmail.com>,
	linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@infradead.org, viro@zeniv.linux.org.uk,
	davem@davemloft.net, netdev@vger.kernel.org, x86@kernel.org,
	mingo@redhat.com, dan.j.williams@intel.com,
	borislav.petkov@amd.com, ying.huang@intel.com, lenb@kernel.org,
	neilb@suse.de, cl@linux-foundation.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753379Ab0AZCF0@vger.kernel.org>
In-Reply-To: <4B5E401D.2020809@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 01/26/2010 10:06 AM, H. Peter Anvin wrote:
>> I guess __percpu is an address_space attribute? Is there no
>> way to force the address space change directly from the
>> per_cpu() macro?
>>
> 
> Hmm... thinking more about it, we should be able to just move the & and
> [0] into the per_cpu() macro, addressing the situation, or does that
> cause problems elsewhere?

Hmmm.... the argument gotta be an lvalue.  Let me try just in case.
Nope, it doesn't work.

Thanks.

-- 
tejun
