From: Andri Yngvason <andri.yngvason@marel.com>
Subject: Re: [PATCH v6 5/7] can: kvaser_usb: Update interface state before exiting on
 OOM
Date: Mon, 26 Jan 2015 10:52:50 +0000
Message-ID: <20150126105250.19943.75012@shannon>
References: <20141223154654.GB6460@vivalin-002>
 <20150126051755.GA3014@Darwish.PC> <20150126052039.GB3014@Darwish.PC>
 <20150126052254.GC3014@Darwish.PC> <20150126052406.GD3014@Darwish.PC>
 <20150126052543.GE3014@Darwish.PC> <20150126052719.GF3014@Darwish.PC>
 <20150126102843.17894.84372@shannon> <54C61BE4.8070105@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Linux-CAN <linux-can@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	"Ahmed S. Darwish" <darwish.07@gmail.com>,
	Olivier Sobrie <olivier@sobrie.be>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <54C61BE4.8070105@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Marc Kleine-Budde (2015-01-26 10:50:12)
> On 01/26/2015 11:28 AM, Andri Yngvason wrote:
> > Quoting Ahmed S. Darwish (2015-01-26 05:27:19)
> >> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> >>
> >> Update all of the can interface's state and error counters before
> >> trying any skb allocation that can actually fail with -ENOMEM.
> >>
> >> Suggested-by: Marc Kleine-Budde <mkl@pengutronix.de>
> >> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> >> ---
> >>  drivers/net/can/usb/kvaser_usb.c |  181 ++++++++++++++++++++++----------------
> >>  1 files changed, 105 insertions(+), 76 deletions(-)
> [..]
> 
> > Looks good to me.
> 
> Can I add your Acked-by to 5-7?
> 
Yes.

--
Andri
