From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: FW: Submission for S2io 10GbE driver
Date: Thu, 05 Feb 2004 04:27:25 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40220C7D.2060503@pobox.com>
References: <20040205015149.GN19011@krispykreme> <005701c3eb92$55dc7650$7310100a@S2IOtech.com> <20040205032519.GR19011@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Leonid Grossman <leonid.grossman@s2io.com>, "'Andi Kleen'" <ak@suse.de>,
        netdev@oss.sgi.com, raghava.vatsavayi@s2io.com, iod00d@hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20040205032519.GR19011@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Anton Blanchard wrote:
> Well there are non byteswapping versions on some architectures
> (__raw_read*/__raw_write*). However at least on ppc32 they dont contain
> memory barriers so you could into trouble using them.


FWIW the __raw_xxx are not supposed to contain memory barriers.  That's 
for when the driver writer decides he is smart enough to do the byte 
swapping and barriers himself, for possibly increased speed :)

	Jeff
