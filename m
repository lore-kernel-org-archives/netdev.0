From: Andri Yngvason <andri.yngvason@marel.com>
Subject: Re: [PATCH v5 2/5] can: kvaser_usb: Consolidate and unify state change
 handling
Date: Wed, 21 Jan 2015 11:00:02 +0000
Message-ID: <20150121110002.18486.29514@shannon>
References: <20141223154654.GB6460@vivalin-002> <20150120214409.GA16828@linux>
 <20150120214537.GB16828@linux> <20150121103319.14511.57709@shannon>
 <54BF8326.3080406@pengutronix.de>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0090.outbound.protection.outlook.com ([157.55.234.90]:10304
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750916AbbAULAL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 06:00:11 -0500
In-Reply-To: <54BF8326.3080406@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Marc Kleine-Budde (2015-01-21 10:44:54)
> On 01/21/2015 11:33 AM, Andri Yngvason wrote:
> > Quoting Ahmed S. Darwish (2015-01-20 21:45:37)
> >> From: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> >>
> >> Replace most of the can interface's state and error counters
> >> handling with the new can-dev can_change_state() mechanism.
> >>
> >> Suggested-by: Andri Yngvason <andri.yngvason@marel.com>
> >> Signed-off-by: Ahmed S. Darwish <ahmed.darwish@valeo.com>
> >> ---
> >>  drivers/net/can/usb/kvaser_usb.c | 114 +++++++++++++++++++--------------------
> >>  1 file changed, 55 insertions(+), 59 deletions(-)
> >>
> >> diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
> >> index 971c5f9..0386d3f 100644
> >> --- a/drivers/net/can/usb/kvaser_usb.c
> >> +++ b/drivers/net/can/usb/kvaser_usb.c
> 
> > Looks good.
> 
> Is this an Acked-by?
> 

ACK.

--
Andri
