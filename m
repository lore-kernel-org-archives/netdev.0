From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 5/8] percpu: add __percpu sparse annotations to x86
Date: Mon, 25 Jan 2010 17:06:36 -0800
Message-ID: <4B5E401C.1050605@zytor.com>
References: <1264432935-10453-1-git-send-email-tj@kernel.org> <1264432935-10453-6-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@infradead.org, viro@zeniv.linux.org.uk,
	davem@davemloft.net, netdev@vger.kernel.org, x86@kernel.org,
	mingo@redhat.com, fweisbec@gmail.com, dan.j.williams@intel.com,
	borislav.petkov@amd.com, ying.huang@intel.com, lenb@kernel.org,
	neilb@suse.de, cl@linux-foundation.org,
	Thomas Gleixner <tglx@linutronix.de>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752764Ab0AZBTP@vger.kernel.org>
In-Reply-To: <1264432935-10453-6-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/25/2010 07:22 AM, Tejun Heo wrote:
> 
> In arch/x86/kernel/cpu/common.c, per_cpu(exception_stacks, cpu) is
> replaced with &per_cpu(exception_stacks[0], cpu) which is equivalent
> except that it allows per_cpu() macro to correctly drop percpu
> designation during sparse pass.
> 

Same comment as Frederic's about this... this kind of uglification
really is unacceptable and needs to be addressed.

Other than that, it looks good.

	-hpa
