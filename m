From: Andi Kleen <ak@colin2.muc.de>
Subject: Re: [PATCH] Add 32bit emulation for wireless
Date: 19 Jan 2004 21:50:16 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119205016.GA51807@colin2.muc.de>
References: <20040119123945.A32623@infradead.org> <20040119141041.2cccbc3d.ak@suse.de> <20040119055615.4380e157.davem@redhat.com> <20040119153919.14102937.ak@suse.de> <20040119063921.586b37ac.davem@redhat.com> <20040119155412.2bffee5a.ak@suse.de> <20040119194943.GA9360@bougret.hpl.hp.com> <20040119210132.0c52df58.ak@suse.de> <20040119201912.GA9701@bougret.hpl.hp.com> <20040119122657.3b432583.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com, jt@bougret.hpl.hp.com, ak@suse.de, hch@infradead.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Mon, 19 Jan 2004 21:50:16 +0100
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040119122657.3b432583.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> 1) they're a lot faster than their 64-bit counterparts
> 
> 2) they're a lot smaller than their 64-bit counterparts
> 
> 3) 64-bits buys them absolutely nothing

Just for the record: this doesn't apply to AMD64. While data structures
take a bit more memory at runtime the 64bit code is a lot better 
due to more registers and better ABI.  And it is also not signifcantly
bigger, in fact some programs get smaller when you recompile them for 
64bit.

Still good 32bit emulation is important because people expect 32bit
applications to run seamlessly on 64bit kernels.

> Therefore the 32-bit compatability layer must be as fully supportive as humanly
> possible.  Most 64-bit platforms still have %99 32-bit distributions.

AMD64 should usually run with 64bit userland, except for user who
transistion slowly from a 32bit user land.

-Andi
