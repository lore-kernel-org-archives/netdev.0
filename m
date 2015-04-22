From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Y2038] [PATCH 04/11] posix timers:Introduce the 64bit methods with timespec64 type for k_clock structure
Date: Wed, 22 Apr 2015 17:37:46 +0200
Message-ID: <2593711.uvCiD7pHri@wuerfel>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org> <2500914.bVUENZ0dAZ@wuerfel> <20150422145432.GA31405@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: y2038@lists.linaro.org, pang.xunlei@linaro.org,
	Peter Zijlstra <peterz@infradead.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Paul Mackerras <paulus@samba.org>, cl@linux.com,
	Ingo Molnar <mingo@kernel.org>, heenasirwani@gmail.com,
	linux-arch@vger.kernel.org, linux-s390@vger.kernel.org,
	mpe@ellerman.id.au, rafael.j.wysocki@intel.com, ahh@google.com,
	Frederic Weisbecker <fweisbec@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, pjt@google.com,
	riel@redhat.com, Martin Schwidefsky <schwidefsky@de.ibm.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>, rth@twiddle.net,
	Baolin Wang <baolin.wang@linaro.org>,
	gregkh@linuxfoundation.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	linux390@de.ibm.com, linuxppc-dev@lists.ozlabs.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20150422145432.GA31405@localhost.localdomain>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 22 April 2015 16:54:32 Richard Cochran wrote:
> On Wed, Apr 22, 2015 at 03:50:45PM +0200, Arnd Bergmann wrote:
> > time, stime, gettimeofday, settimeofday, adjtimex, nanosleep,
> > getitimer, setitimer:
> >  all deprecated => wontfix
> 
> If adjtimex is deprecated, what will replace it?  It is really
> important for ntp.

clock_adjtime(). Basically all all the basic time related syscalls
are superceded by the clock_* calls that can take a clockid argument.

	Arnd
