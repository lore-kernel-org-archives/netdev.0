From: Andi Kleen <ak@suse.de>
Subject: Re: reserving skbuffs for the drivers
Date: Mon, 21 Oct 2002 05:20:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021021052031.B16412@wotan.suse.de>
References: <3DB31A32.9020107@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <3DB31A32.9020107@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 20, 2002 at 02:03:46PM -0700, Ben Greear wrote:
> I'm getting dropped rx packets because the network
> driver cannot allocate an skbuf in time, evidently....
> 
> I have 256MB of RAM, is there some way to increase the amount of RAM
> that the kernel keeps around for GFP_ATOMIC allocations?
> 
> Documentation I find talks about buffermem and freepages, which looks
> hopeful, but they appear to no longer be in the proc file system as
> tunables???

You should be asking on linux-mm, not on netdev.

I've been complaining to the MM guys for years that they dropped freepages 
in 2.4, which makes it impossible to tune the VM for heavy network load, but 
so far nobody was interested in fixing it.

-Andi
