From: Andi Kleen <ak@suse.de>
Subject: Re: Bad UDP checksum with 82540EM
Date: Sun, 8 Feb 2004 07:46:43 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040208074643.482ab4c7.ak@suse.de>
References: <OFE5352D34.67E10D98-ON87256E33.00725857-86256E33.0076C481@us.ibm.com>
	<je3c9mv7ea.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jonmason@us.ibm.com, cramerj@intel.com, netdev@oss.sgi.com,
        netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Schwab <schwab@suse.de>
In-Reply-To: <je3c9mv7ea.fsf@sykes.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 07 Feb 2004 23:42:21 +0100
Andreas Schwab <schwab@suse.de> wrote:

> Jon D Mason <jonmason@us.ibm.com> writes:
> 
> > This probably isn't helpful, but it sounds like a hardware error.  Is the 
> > error occurring on multiple/all HP adapters, or only one? 
> 
> I've also seen it with a HP branded BCM5701 on IA64, but also with a
> Broadcom BCM5702 on AMD64 (both using the tg3 driver).  It seems like
> broken UDP checksumming is rather common. :-(

It could be still a software bug.  When hardware checksumming is available
the UDP packets use a slightly different path through the stack.

Could you perhaps test if the problem occurs in a 32bit box with the 
same NIC ? Maybe it is some 64bit problem somewhere in software.

-Andi
