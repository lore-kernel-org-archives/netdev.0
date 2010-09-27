From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v6 0/8] ptp: IEEE 1588 hardware clock support
Date: Mon, 27 Sep 2010 18:05:58 +0100
Message-ID: <20100927180558.52817d5f@lxorguk.ukuu.org.uk>
References: <cover.1285261533.git.richard.cochran@omicron.at>
	<20100923213654.0c64b047@lxorguk.ukuu.org.uk>
	<20100924131407.GA3113@riccoc20.at.omicron.at>
	<20100924150246.0e6064b6@lxorguk.ukuu.org.uk>
	<alpine.DEB.2.00.1009271054320.9258@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Stultz <johnstul@us.ibm.com>, Rodolfo Giometti <giometti@linux.it>,
	Arnd Bergmann <arnd@arndb.de>,
	Peter Zijlstra <peterz@infradead.org>, linux-api@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
	linuxppc-dev@lists.ozlabs.org, Richard Cochran <richardcochran@gmail.com>,
	linux-arm-kernel@lists.infradead.org, Krzysztof Halasa <khc@pm.waw.pl>
To: Christoph Lameter <cl@linux.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <alpine.DEB.2.00.1009271054320.9258@router.home>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Mon, 27 Sep 2010 10:56:09 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> 
> On Fri, 24 Sep 2010, Alan Cox wrote:
> 
> > Whether you add new syscalls or do the fd passing using flags and hide
> > the ugly bits in glibc is another question.
> 
> Use device specific ioctls instead of syscalls?

Some of the ioctls are probably not device specific, the job of the OS in
part is to present a unified interface. We already have a mess of HPET
and RTC driver ioctls.

Some of it undoubtedly is device specific.

Alan
