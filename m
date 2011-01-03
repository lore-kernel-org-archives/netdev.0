From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH V8 08/13] posix clocks: cleanup the CLOCK_DISPTACH macro
Date: Mon, 03 Jan 2011 10:29:09 +0100
Message-ID: <1294046949.2016.36.camel@laptop>
References: <cover.1293820862.git.richard.cochran@omicron.at>
	 <503cd1fa268867573001cfc9bb5681ee3b5b32fa.1293820862.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <503cd1fa268867573001cfc9bb5681ee3b5b32fa.1293820862.git.richard.cochran@omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-12-31 at 20:15 +0100, Richard Cochran wrote:
> +#define CLOCK_DISPATCH(clock, call, arglist) dispatch_##call arglist

How about you run something like:

 :% s/CLOCK_DISPATCH([^,]*, \([^,]*\), \([^)]*)\))/dispatch_\1\2/g

and remove that cruft all together?
