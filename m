From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] [1/2] kernel error reporting (revised)
Date: Fri, 18 Jul 2003 11:53:06 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0307181148340.5813-100000@excalibur.intercode.com.au>
References: <3F16F54C.949A9299@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, <davem@redhat.com>,
   <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>, <jgarzik@pobox.com>,
   <alan@lxorguk.ukuu.org.uk>, <rddunlap@osdl.org>, <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jim Keniston <jkenisto@us.ibm.com>
In-Reply-To: <3F16F54C.949A9299@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Jul 2003, Jim Keniston wrote:

> 3. Given the above, what should the evlog.c caller do when
> kernel_error_event_iov() returns -EINPROGRESS?
> a. Nothing.  Figure the packet will probably get logged.
> b. Just to be safe, report it via printk, the same way we report dropped
> packets.
> We currently do (a).  (b) would mean that every event logged from IRQ
> context would be cc-ed to printk.

I don't think this irq detection logic should be added at all here, let 
the caller reschedule its logging if running in irq context.


- James
-- 
James Morris
<jmorris@intercode.com.au>
