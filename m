From: Joe Perches <joe@perches.com>
Subject: Re: [patch 08/12] can: c_can: Makethe code readable
Date: Tue, 18 Mar 2014 10:37:00 -0700
Message-ID: <1395164220.2812.59.camel@joe-AO722>
References: <20140318171007.528610837@linutronix.de>
	 <20140318171127.430027680@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140318171127.430027680@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-03-18 at 17:19 +0000, Thomas Gleixner wrote:

[patch]

Hi

The multi-while loop

	while ((obj = ffs(pend)) && quota > 0) {
		...
	} while ((obj = ffs(pend)) && quota > 0);

looks, umm, unusual.
