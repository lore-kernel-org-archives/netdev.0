From: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah@gmail.com>
Subject: Re: [PATCH V7 1/8] ntp: add ADJ_SETOFFSET mode bit
Date: Wed, 22 Dec 2010 06:13:06 +0900
Message-ID: <AANLkTikHV-qN73Zvvvxn76vtFFKG_VNTQhF3qpqTnOrE@mail.gmail.com>
References: <cover.1292512461.git.richard.cochran@omicron.at>
 <880d82bb8120f73973db27e0c48e949014b1a106.1292512461.git.richard.cochran@omicron.at>
 <AANLkTi=yGoFwYt4p_LeHtAQyYgmURspO-p57UdL0sUEZ@mail.gmail.com> <1292960224.2618.4.camel@work-vm>
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
In-Reply-To: <1292960224.2618.4.camel@work-vm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 22, 2010 at 4:37 AM, john stultz <johnstul@us.ibm.com> wrote:
> adjtimex is a linux specific interface, which is compatible but not
> identical to the ntp specified interfaces. The ntp client code already
> has Linux specific modifications, so I don't think we have to worry
> about 0x40 specifically being reserved by the NTP client.

But struct timex is not linux-specific...
