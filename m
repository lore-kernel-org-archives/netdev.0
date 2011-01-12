From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V8 08/13] posix clocks: cleanup the CLOCK_DISPTACH macro
Date: Wed, 12 Jan 2011 13:17:52 +0100
Message-ID: <20110112121752.GA2800@riccoc20.at.omicron.at>
References: <cover.1293820862.git.richard.cochran@omicron.at>
 <503cd1fa268867573001cfc9bb5681ee3b5b32fa.1293820862.git.richard.cochran@omicron.at>
 <alpine.LFD.2.00.1101111224280.12146@localhost6.localdomain6>
 <20110112073728.GA2935@riccoc20.at.omicron.at>
 <alpine.LFD.2.00.1101121201080.12146@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1101121201080.12146@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 12, 2011 at 12:16:10PM +0100, Thomas Gleixner wrote:
> 
> We probably can remove the dispatch inlines that way completely and do
> the call directly from the syscall function.

Right, okay. I also wanted to put the whole logic into the syscall
itself. I'll try it that way.

Thanks,

Richard
