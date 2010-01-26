From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET] percpu: add __percpu sparse annotations
Date: Tue, 26 Jan 2010 09:30:53 +0900
Message-ID: <4B5E37BD.5020400@kernel.org>
References: <1264432935-10453-1-git-send-email-tj@kernel.org> <20100125231411.GA19799@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@infradead.org, davem@davemloft.net,
	netdev@vger.kernel.org, x86@kernel.org, mingo@redhat.com,
	fweisbec@gmail.com, dan.j.williams@intel.com,
	borislav.petkov@amd.com, ying.huang@intel.com, lenb@kernel.org,
	neilb@suse.de, cl@linux-foundation.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751770Ab0AZAZk@vger.kernel.org>
In-Reply-To: <20100125231411.GA19799@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 01/26/2010 08:14 AM, Al Viro wrote:
> Um.  Where *is* the definition of __percpu?  Presumably, that'd be
> something like __attribute__((noderef,address_space(4)) under ifdef
> __CHECKER__ and empty otherwise?  If so, I'm fine with that patchset,
> provided that it does grow that #define and becomes self-contained...

Ah... sorry, I forgot about the base tree.  The definition has been in
the percpu tree for some time now.  The patchset is on top of the
following branch.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/percpu.git for-next

and the series is available as git tree in the following branch.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/percpu.git percpu-sparse-review

The definition is in include/linux/compiler.h.

# define __percpu	__attribute__((noderef, address_space(3)))

which gets replaced by dummy def if !__CHECKER__.

Thanks.

-- 
tejun
