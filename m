From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: patch submission question
Date: Fri, 21 May 2004 16:45:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40AE6A71.1070305@pobox.com>
References: <200405201543.i4KFhHk08317@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Don Fry <brazilnut@us.ibm.com>
In-Reply-To: <200405201543.i4KFhHk08317@DYN318364BLD.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> Jeff,
> 
> I have four one-line patches for the pcnet32 driver.  Should I send them
> as one patch, or four one-line patches?
> 
> 1) Change PCnet/FAST III 79C976 to PCnet/PRO 79C976.
> 2) In pcnet32_interrupt change (delta >= TX_RING_SIZE) to  (... > ...)
> 3) add 'static' to pcnet32_get_regs and pcnet32_get_regs_len.
>     (prototype has static, routine does not have static).
> 4) reading bcr34 hangs the system with some variants of the chip in
> pcnet2_get_regs.


Sorry I didn't get back to you before you actually sent the patches. 
Life is what it is...  Also, I hope you don't mind me adding a CC to 
netdev@oss.sgi.com.  Even for questions like the above, I _really_ 
encourage you to CC the mailing list, that way all knowledge (including 
my preferences) are shared and archived.  This is another part of open 
development.

The main point is to separate things out into logical changes.  For 
practical purposes, this usually means I will often lump several minor 
changes into a single patch.  It is up to you, the maintainer, to decide 
where to draw the line.

In your above example, I would send #2 and #4 as separate patches, and 
combine #1 and #3 into a single "trivial changes" patch.

	Jeff
