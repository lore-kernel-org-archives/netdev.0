From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v4 1/1] can: add pruss CAN driver.
Date: Wed, 11 May 2011 23:56:52 +0100
Message-ID: <20110511235652.7ccddb3b@lxorguk.ukuu.org.uk>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>
	<2BFFDAA0A0DE4820876E5549867938EC@subhasishg>
	<201105112331.47954.arnd@arndb.de>
	<201105112344.44171.arnd@arndb.de> <4DCB103B.30801@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sachi@mistralsolutions.com, davinci-linux-open-source@linux.davincidsp.com,
	Arnd Bergmann <arnd@arndb.de>,
	Subhasish Ghosh <subhasish@mistralsolutions.com>, nsekhar@ti.com,
	open list <linux-kernel@vger.kernel.org>,
	CAN NETWORK DRIVERS <socketcan-core@lists.berlios.de>,
	Wolfgang Grandegger <wg@grandegger.com>, Netdev@vger.kernel.org,
	m-watkins@ti.com, linux-arm-kernel@lists.infradead.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <4DCB103B.30801@pengutronix.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

> I'm not sure if reprogramming hardware filters on the fly works on evey
> can core. The more conservative solution would be to configure the
> filter list globally (+when the interface is down) via netlink.

For anything that isn't so braindead it ought to be done on the fly and
behind the users back to avoid having to make app code specially aware.
If the lists are fixed either in firmware or in software the stack needs
to error attempts to use anything else - and as you say you need some
kind of way to configure those global lists, preferably portably.

Alan
