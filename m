From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] net: mvneta: Add missing hotplug notifier transition
Date: Fri, 11 Mar 2016 11:48:40 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1603111146310.3657@nanos>
References: <1457687423-39784-1-git-send-email-anna-maria@linutronix.de> <8737rx2tqw.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Anna-Maria Gleixner <anna-maria@linutronix.de>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rt@linutronix.de
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8737rx2tqw.fsf@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory,

On Fri, 11 Mar 2016, Gregory CLEMENT wrote:
>  On ven., mars 11 2016, Anna-Maria Gleixner <anna-maria@linutronix.de> wrote:
> 
> > The mvneta_percpu_notifier() hotplug callback lacks handling of the
> > CPU_DOWN_FAILED case. That means, if CPU_DOWN_PREPARE failes, the
> > driver is not well configured on the CPU.
> >
> > Add handling for CPU_DOWN_FAILED[_FROZEN] hotplug notifier transition
> > to setup the driver.
> 
> I agree that we need to handle this case, however reusing CPU_ONLINE
> case for it seems too much.

Why is that too much? If it does the job, then it's definitely preferrable
over an extra case for a non hotpath error handling operation.

Thanks,

	tglx
