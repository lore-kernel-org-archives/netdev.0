From: Anton Blanchard <anton@samba.org>
Subject: Re: FW: Submission for S2io 10GbE driver
Date: Thu, 5 Feb 2004 14:25:20 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040205032519.GR19011@krispykreme>
References: <20040205015149.GN19011@krispykreme> <005701c3eb92$55dc7650$7310100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Andi Kleen'" <ak@suse.de>, netdev@oss.sgi.com,
        raghava.vatsavayi@s2io.com, iod00d@hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
Content-Disposition: inline
In-Reply-To: <005701c3eb92$55dc7650$7310100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
> We are submitting for inclusion in 2.6 kernel but we'd like to have same
> code for 
> 2.4 kernels as well, most our customers will stay with 2.4 for a
> while... If you add the bits to 2.6, we would still need a solution for
> 2.4 kernel.

OK, It should be easy to get the readq/writeq macros put into 2.4 as well.

> > Thats how all big endian platforms work. in* and out*, read* 
> > and write* byteswap. 
> 
> So, we should make the code big endian specific rather than PPC64
> specific, right?

Well there are non byteswapping versions on some architectures
(__raw_read*/__raw_write*). However at least on ppc32 they dont contain
memory barriers so you could into trouble using them.

What does your code look like? You could key off __BIG_ENDIAN if you
really need to. Is it performance critical?

Anton
