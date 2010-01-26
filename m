From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 7/8] percpu: add __percpu sparse annotations to
	hw_breakpoint
Date: Tue, 26 Jan 2010 02:04:52 +0000
Message-ID: <20100126020452.GB19799@ZenIV.linux.org.uk>
References: <1264432935-10453-1-git-send-email-tj@kernel.org> <1264432935-10453-8-git-send-email-tj@kernel.org> <20100126001901.GI5087@nowhere> <4B5E3F2C.2010702@zytor.com> <4B5E4E12.7060900@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@infradead.org, davem@davemloft.net,
	netdev@vger.kernel.org, x86@kernel.org, mingo@redhat.com,
	dan.j.williams@intel.com, borislav.petkov@amd.com,
	ying.huang@intel.com, lenb@kernel.org, neilb@suse.de,
	cl@linux-foundation.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753438Ab0AZCFr@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B5E4E12.7060900@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 26, 2010 at 11:06:10AM +0900, Tejun Heo wrote:
> Hello,
> 
> On 01/26/2010 10:02 AM, H. Peter Anvin wrote:
> > A cast (using __typeof__) combined with an address space override?
> 
> That still puts the address specification at the wrong level.  The
> problem is that the __typeof__ would be an array type which itself
> doesn't have address space set but its members are in address space 3.
> So, you need to get *inside* the array type def to change that.  :-(

Could you post the actual definitions in one piece?  Would be easier to
discuss what's going on...
