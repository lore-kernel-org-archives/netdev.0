From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/5] r8169: auto detect 32-bit slot
Date: Thu, 10 Mar 2005 01:45:25 +0100
Message-ID: <20050310004525.GA12735@electric-eye.fr.zoreil.com>
References: <20050309112925.7f7900ab@dxpl.pdx.osdl.net> <m17jkgwp6i.fsf@muc.de> <20050309214023.GA9502@electric-eye.fr.zoreil.com> <20050309135530.5c5c80b6@dxpl.pdx.osdl.net> <20050309230809.GC9502@electric-eye.fr.zoreil.com> <20050309232024.GC63395@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
To: Andi Kleen <ak@muc.de>
Content-Disposition: inline
In-Reply-To: <20050309232024.GC63395@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen <ak@muc.de> :
[...]
> The concept of "64bit systems" is useless here anyways. Even on a 32bit
> system with highmem like i386 you can get >32bit addresses to deal
> with. One usecase for that would be sendfile() out of user space.
> This is widely used these days.

The combination "32 bit system with weird addressing mode + r8169 adapter"
has accounted for 0 bug/success report so far and I do not know a single
tester for it anyway. Whence my narrow-minded view of the issue :o)

[...]
> Again are you sure it depends on 64bit slots? Normally 64bit slots
> only offer more bandwidth, but the address protocol is the same
> as 32bit and both support DAC in the same way.

I do not know. The 8169 includes a register which tells (various things +)
the bus width. Without further documentation, I do not see how the relevance
of this register can be established/discarded if the aforementioned
test-cases are not experienced.

[...]
> You really should forget about amd64 or not, all that counts is
> sizeof(dma_addr_t) 

(assuming the on-board 8169 is wired correctly, be it on-board or not, yes)

--
Ueimor
