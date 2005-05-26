From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: getting eth1: Memory squeeze, dropping packet message
Date: Thu, 26 May 2005 11:22:11 -0500
Message-ID: <200505261122.11552.jdmason@us.ibm.com>
References: <20050526144058.11890.qmail@web33004.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: net dev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: cranium2003 <cranium2003@yahoo.com>
In-Reply-To: <20050526144058.11890.qmail@web33004.mail.mud.yahoo.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 26 May 2005 09:40 am, cranium2003 wrote:
> Hello,
>        While transmitting packets through linux Router
> host from one network to another Redhat linux 9 kernel
> 2.4.20-8 caught kernel oops following there are 2
> statements which are
> __alloc_pages: 0 order allocation failed (gfp =
> 0x20/1)
> eth1: Memory squeeze, dropping packet
> What this means? 

The driver was trying to alloc a rx skb and couldn't.  The incoming packet was 
dropped.  Assuming that the error logged is the only problem you saw, this 
isn't a driver or kernel bug.  It means you were out of free kernel memory. 

You can see if you have any processes consuming lots of memory.

Thanks,
Jon
