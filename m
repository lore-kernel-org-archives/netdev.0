From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: FW: Submission for S2io 10GbE driver
Date: Wed, 4 Feb 2004 18:46:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <005701c3eb92$55dc7650$7310100a@S2IOtech.com>
References: <20040205015149.GN19011@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <raghava.vatsavayi@s2io.com>, <iod00d@hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Anton Blanchard'" <anton@samba.org>, "'Andi Kleen'" <ak@suse.de>
In-Reply-To: <20040205015149.GN19011@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> > > 1) We did't find quad word memory operations(writeq and readq) on 
> > > PCI bus for PPC64 architecture.
> > 
> > That's a bug in ppc64 then. Can you complain to them?  I would go 
> > ahead and just use them in the driver unconditionally and 
> wait for the 
> > ppc64 to fix it. Or just add them there, it's probably simple.
> 
> Yep ppc64 should define them. If you are submitting a driver 
> for inclusion in 2.6 leave these bits out, its my fault they 
> arent defined and I'll get them added in.

Hi Anton,
We are submitting for inclusion in 2.6 kernel but we'd like to have same
code for 
2.4 kernels as well, most our customers will stay with 2.4 for a
while... If you add the bits to 2.6, we would still need a solution for
2.4 kernel.

> > > On a little endian m/c like IA32 also writel writes same 
> values in a 
> > > similar manner as shown above. So the question is -
> > > Do all big endian machines with linux OS swap the values 
> and write in
> > > little endian format?? 
> > 
> > I hope not.
> 
> Thats how all big endian platforms work. in* and out*, read* 
> and write* byteswap. 

So, we should make the code big endian specific rather than PPC64
specific, right?

Thanks, Leonid
