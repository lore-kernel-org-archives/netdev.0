From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: FW: Submission for S2io 10GbE driver
Date: Thu, 05 Feb 2004 04:29:57 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40220D15.60603@pobox.com>
References: <005701c3eb92$55dc7650$7310100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'Anton Blanchard'" <anton@samba.org>, "'Andi Kleen'" <ak@suse.de>,
        netdev@oss.sgi.com, raghava.vatsavayi@s2io.com, iod00d@hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Leonid Grossman <leonid.grossman@s2io.com>
In-Reply-To: <005701c3eb92$55dc7650$7310100a@S2IOtech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Leonid Grossman wrote:
>>Thats how all big endian platforms work. in* and out*, read* 
>>and write* byteswap. 
> 
> 
> So, we should make the code big endian specific rather than PPC64
> specific, right?


{read,write}[bwlq] should work the same regardless of whether its big 
endian or little endian.  The rule is "PCI is defined to be little 
endian".  On little endian platforms, no byte swapping occurs.  On big 
endian platforms, the platform will byteswap.  Thus, the driver should 
not have big-endian-specific or PPC64-specific code...

(you still have to do your own byteswapping for DMA)

	Jeff
