From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH / RFC 2/2] fec: fixup spinlocks.
Date: Fri, 28 Mar 2008 20:24:14 +1000
Message-ID: <47ECC74E.6010302@snapgear.com>
References: <20080327140041.072611004@linutronix.de>
	<20080327140120.068976876@linutronix.de>
	<47EC9701.4090504@snapgear.com>
	<20080328092440.GC27124@www.tglx.de>
Reply-To: uClinux development list <uclinux-dev@uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>,
	uclinux-dev@uclinux.org
To: Sebastian Siewior <bigeasy@linutronix.de>
Return-path: <uclinux-dev-bounces@uclinux.org>
In-Reply-To: <20080328092440.GC27124@www.tglx.de>
List-Unsubscribe: <http://mailman.uclinux.org/mailman/listinfo/uclinux-dev>,
	<mailto:uclinux-dev-request@uclinux.org?subject=unsubscribe>
List-Archive: <http://mailman.uclinux.org/pipermail/uclinux-dev>
List-Post: <mailto:uclinux-dev@uclinux.org>
List-Help: <mailto:uclinux-dev-request@uclinux.org?subject=help>
List-Subscribe: <http://mailman.uclinux.org/mailman/listinfo/uclinux-dev>,
	<mailto:uclinux-dev-request@uclinux.org?subject=subscribe>
Sender: uclinux-dev-bounces@uclinux.org
Errors-To: uclinux-dev-bounces@uclinux.org
List-Id: netdev.vger.kernel.org

Hi Sebastion,

Sebastian Siewior wrote:
> * Greg Ungerer | 2008-03-28 16:58:09 [+1000]:
> 
>> Hi Sebastion,
> Hi Greg,
> 
>>> 4. Use the .*_irqsave variant in that part which may be called from IRQ or
>>> user mode.
>> I couldn't see any changes here that switched to use *_irqsave?
> The only lock user that may be called from both called from both places
> is mii_queue() and that one allready uses the save variant.
> I guess you want me to repost that patch without point 4 in the summary
> right?

No, don't worry about it.
I just wanted to make sure there wasn't more to the patch.

Thanks
Greg


------------------------------------------------------------------------
Greg Ungerer  --  Chief Software Dude       EMAIL:     gerg@snapgear.com
SnapGear -- a Secure Computing Company      PHONE:       +61 7 3435 2888
825 Stanley St,                             FAX:         +61 7 3891 3630
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com
_______________________________________________
uClinux-dev mailing list
uClinux-dev@uclinux.org
http://mailman.uclinux.org/mailman/listinfo/uclinux-dev
This message was resent by uclinux-dev@uclinux.org
To unsubscribe see:
http://mailman.uclinux.org/mailman/options/uclinux-dev
