From: Matt Mackall <mpm@selenic.com>
Subject: Re: [RFC] TCP congestion schedulers
Date: Wed, 30 Mar 2005 01:41:24 -0800
Message-ID: <20050330094124.GG25554@waste.org>
References: <20050311120054.4bbf675a@dxpl.pdx.osdl.net> <20050311201011.360c00da.davem@davemloft.net> <20050314151726.532af90d@dxpl.pdx.osdl.net> <m13bur5qyo.fsf@muc.de> <Pine.LNX.4.58.0503211605300.6729@dexter.psc.edu> <20050322074122.GA64595@muc.de> <20050328155117.7c5de370@dxpl.pdx.osdl.net> <20050329152538.GF63268@muc.de> <20050329091725.4f955ee7@dxpl.pdx.osdl.net> <4249A570.90709@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
Content-Disposition: inline
In-Reply-To: <4249A570.90709@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 29, 2005 at 10:58:56AM -0800, Rick Jones wrote:
> <excerpt>
> 
> McKinley-type cores (includes Madison, etc.)
> do not have indirect branch target hardware.  Instead, indirect
> branches are executed as follows:
[...] 
> (1) To _guarantee_ correct prediction, the branch register has to be
>     loaded way before the indirect branch direction (at least 6
>     front-end L1I cache accesses; which is up to 6 bundle-pairs or 36
>     instructions, I believe).

That's horrendous. Indirect calls are a performance win vs conditional
branching on more sensible architectures and it's used quite
extensively in various parts of the kernel. It really makes one wonder
if dealing with this quirk is worth the trouble.

-- 
Mathematics is the supreme nostalgia of our time.
