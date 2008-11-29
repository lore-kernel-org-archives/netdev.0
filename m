From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 0/6] fs: Scalability of sockets/pipes
	allocation/deallocation on SMP
Date: Sat, 29 Nov 2008 01:38:17 -0500
Message-ID: <20081129063816.GA869@infradead.org>
References: <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com> <20081121152148.GA20388@elte.hu> <4926D39D.9050603@cosmosbay.com> <20081121153453.GA23713@elte.hu> <492DDB6A.8090806@cosmosbay.com> <20081128180318.GL10487@elte.hu> <1227898076.7392.16.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1227898076.7392.16.camel@twins>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 28, 2008 at 07:47:56PM +0100, Peter Zijlstra wrote:
> > Wow, that's incredibly impressive! :-)
> 
> Yeah, we got a similar speedup on -rt by pushing those super-block files
> list into per-cpu lists and doing crazy locking on them.
> 
> Of course avoiding them all together, like done here is a nicer option
> but is sadly not a possibility for regular files (until hch gets around
> to removing the need for the list).

We should have finished this long ago, thanks for the reminder.
