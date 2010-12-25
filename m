From: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah@gmail.com>
Subject: Re: [PATCH V7 1/8] ntp: add ADJ_SETOFFSET mode bit
Date: Sun, 26 Dec 2010 05:38:57 +0900
Message-ID: <AANLkTind84BVd=2Z07Sz+JfpVRH7m8wdx37YhRcqkCZv@mail.gmail.com>
References: <cover.1292512461.git.richard.cochran@omicron.at>
 <880d82bb8120f73973db27e0c48e949014b1a106.1292512461.git.richard.cochran@omicron.at>
 <AANLkTi=yGoFwYt4p_LeHtAQyYgmURspO-p57UdL0sUEZ@mail.gmail.com>
 <20101221075612.GA13626@riccoc20.at.omicron.at> <AANLkTimJd5pScKTiDxuYd-h+NevYbCusyvUAqmUDXe8h@mail.gmail.com>
 <1292970355.2618.76.camel@work-vm> <AANLkTimmTzH8+fSYmbajqZ+hU5Ps-UZaTp_1TYzjHB6P@mail.gmail.com>
 <20101223061359.GA7169@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: john stultz <johnstul@us.ibm.com>, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101223061359.GA7169@riccoc20.at.omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After all, I'd prefer your earlier patchset.  Leaving aside the
compatibility issue, there's no particular reason we have to re-use
the struct timex, which requires otherwise unnecessary conditional
branches as well as unit conversions.  Don't you agree?
