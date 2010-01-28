From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: PROBLEM: reproducible crash KVM+nf_conntrack all recent 2.6
 kernels
Date: Thu, 28 Jan 2010 06:21:00 -0500
Message-ID: <1264677660.2793.128.camel@tonnant>
References: <b6fcc0a1001280119t1394d956paa4865c078b52c9f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <b6fcc0a1001280119t1394d956paa4865c078b52c9f@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-01-28 at 11:19 +0200, Alexey Dobriyan wrote:
> > RIP: 0010:[<ffffffff813b4115>]  [<ffffffff813b4115>] destroy_conntrack+0x82/0x114
> 
> Rebuild kernel with CONFIG_DEBUG_INFO=y.
> Double sure conntracking is compiled-in.
> Then run
> 
>     addr2line -e vmlinux $RIP
> 
> it will tell exact line where kernel is oopsing.

I posted a followup with that detail later in the thread. In every case
the kernel has CONFIG_DEBUG_INFO set, and in the latter example I posted
I had turned on almost every other debugging option. I currently have a
kernel with netfilter debugging turned on but that's proving harder to
cause to fall over (likely because I changed several other options, so I
will rebuild it to be identical to earlier with just NF debug on).

Jon.


