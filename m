From: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah@gmail.com>
Subject: Re: [PATCH V8 02/13] ntp: add ADJ_SETOFFSET mode bit
Date: Thu, 13 Jan 2011 05:39:04 +0900
Message-ID: <AANLkTikYuYwb4BLsU3BF_=d9fAdcfb0AC2itDBeyFsNq@mail.gmail.com>
References: <cover.1293820862.git.richard.cochran@omicron.at>
 <fe2bec763bec155381d62721aa9da84aeca2785c.1293820862.git.richard.cochran@omicron.at>
 <AANLkTini2WdT-1v4k9V3JOZYDkA59P+SyscTe8-fK2Wk@mail.gmail.com>
 <20110108175028.GA22308@riccoc20.at.omicron.at> <AANLkTikigXGSACF6R6kfNHyKZ7GFWrUrCMxygvL3fUC6@mail.gmail.com>
 <1294678145.3068.6.camel@work-vm> <AANLkTikdg4Pb5c4wcCU3d3Eku=mpiW_TEkBz0A2VPdVp@mail.gmail.com>
 <1294693597.3068.12.camel@work-vm> <AANLkTik+2udoJ6JyZMhkd1yhr2W9hSWO_vD_zdm+BoOG@mail.gmail.com>
 <1294779309.3441.66.camel@work-vm>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Cochran <richardcochran@gmail.com>,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: john stultz <johnstul@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294779309.3441.66.camel@work-vm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 12, 2011 at 5:55 AM, john stultz <johnstul@us.ibm.com> wrote:
> So the kernel handles leap second insertion via a timer. Thus at the end
> of 23:59:59, it will inject a leapsecond by setting the time back by one
> second (back to 23:59:59) and setting the TIME_OOP flag.
>
> This timer is an absolute timer, so if someone moves the clock forward
> across the 23:59:59 boundary, the adjustment will still be made.
>
> The patch is not broken, nor useless.

It takes into account only one upcoming leap second, but ignores all
the others.  That's not sufficient for arbitrary adjustments.
