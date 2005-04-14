From: Jean-Baptiste Note <jean-baptiste.note@wanadoo.fr>
Subject: Re: Question on prism54 driver
Date: Thu, 14 Apr 2005 13:25:38 +0200
Message-ID: <87r7hdwqfh.fsf@gxaafoot.homelinux.org>
References: <87fyxu5oin.fsf@gxaafoot.homelinux.org>
	<87hdi9sp93.fsf@farside.sncag.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Rainer Weikusat <rainer.weikusat@sncag.com>
In-Reply-To: <87hdi9sp93.fsf@farside.sncag.com> (Rainer Weikusat's message
	of "Thu, 14 Apr 2005 11:04:40 +0200")
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Sender: prism54-devel-bounces@prism54.org
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


Hello Rainer, dear list,

First of all, thanks for your quick reply, which is very enlightening.

> <sigh>
> No, you are just hacking the code without even having tried to
> understand
>
> 	a) what it is doing
>       b) why it does this
> [which, "by coincedence", happens to be the reason that this driver is
>  so thouroughly broken]
> </sigh>

Please don't let my dumb questions shed a bad light on the prism54
developers as a whole.

I have no doubt that such questions would be obvious to core prism54
developers; i only have reverse-engeneered the softmac usb protocol and
am trying to use the prism54 code to do a pci version of the softmac usb
driver. Rest assured that i will not touch the main prism54 code.

> which means they have to be synced everytime the CPU intends to access
> them after they were accessed by the DMA engine.  The skbuffs used by
> the data transfer code are mapped before they are passed to the device
> and unmapped (which syncs them) before the CPU accesses them. This
> isn't needed for the control block, because it is a consistent and not
> a streaming mapping.

Thank you for taking the time to look into this and answering so
thoroughly. I missed the call to pci_unmap_single, and didn't know about
the consistent mapping meaning.

> BTW, I shouldn't be telling you how your code works, don't you think
> so?

I'm sorry my listing as a prism54 developer may lead to some confusion,
and adversely affect all people in prism54 in addition to making a fool
of myself. This has raised my awareness level. Thanks also for this :)

JB

-- 
Jean-Baptiste Note
+33 (0)6 83 03 42 38
jean-baptiste.note@wanadoo.fr
