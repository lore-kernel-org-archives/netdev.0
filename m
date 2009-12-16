From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 4/7] can/at91: don't check platform_get_irq's return value
 against zero
Date: Wed, 16 Dec 2009 17:27:03 +0100
Message-ID: <4B290A57.3010705@grandegger.com>
References: <1260979809-24811-1-git-send-email-u.kleine-koenig@pengutronix.de> <1260979809-24811-2-git-send-email-u.kleine-koenig@pengutronix.de> <1260979809-24811-3-git-send-email-u.kleine-koenig@pengutronix.de> <1260979809-24811-4-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, David Vrabel <dvrabel@arcom.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>,
	netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935017AbZLPQ17@vger.kernel.org>
In-Reply-To: <1260979809-24811-4-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Uwe Kleine-K=F6nig wrote:
> platform_get_irq returns -ENXIO on failure, so !irq was probably
> always true.  Better use (int)irq <=3D 0.  Note that a return value o=
f
> zero is still handled as error even though this could mean irq0.

But only on ARM, which is the only platform still using the infamous
NO_IRQ (=3D-1). As this is a driver for ARM hardware, using irq =3D=3D =
NO_IRQ
would make sense, though.

Wolfgang.
