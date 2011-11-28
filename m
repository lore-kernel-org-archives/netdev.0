From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [Socketcan-users] [PATCH net-next v2 1/4] can: cc770: add driver core for the Bosch CC770 and Intel AN82527
Date: Mon, 28 Nov 2011 14:01:41 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AEE8@saturn3.aculab.com>
References: <4ED3941D.3070302@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <socketcan-users@lists.berlios.de>,
	<linux-can@vger.kernel.org>
To: "Marc Kleine-Budde" <mkl@pengutronix.de>,
	"Wolfgang Grandegger" <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4ED3941D.3070302@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> >   enum {
> > 	CC770_OBJ_RX0 = 0,	/* for receiving normal messages */
> > 	CC770_OBJ_RX1,		/* for receiving normal messages */
> > 	CC770_OBJ_RX_RTR0,	/* for receiving remote transmission
requests */
> > 	CC770_OBJ_RX_RTR1,	/* for receiving remote transmission
requests */
> > 	CC770_OBJ_TX,		/* for sending messages */
> > 	CC770_OBJ_MAX  <================
> 
> ...then add a "," here :P

Not if the code might have to go through the C++ compiler.
C++ doesn't allow a trailing , in enums (some compilers
will error this....).

	David


