From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>
Subject: [PATCH v2 00/15] mark const init data with __initconst instead of
 __initdata
Date: Fri, 30 Mar 2012 22:03:58 +0200
Message-ID: <20120330200358.GV15647@pengutronix.de>
References: <20120329211131.GA31250@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Lunn <andrew@lunn.ch>, Christoph Lameter <cl@linux-foundation.org>,
 linux-mips@linux-mips.org, Tony Lindgren <tony@atomide.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Linus Walleij <linus.walleij@linaro.org>,
 Matt Porter <mporter@kernel.crashing.org>,
 Nicolas Ferre <nicolas.ferre@atmel.com>, Matthew Garrett <mjg59@srcf.ucam.org>,
 platform-driver-x86@vger.kernel.org, Grant Likely <grant.likely@secretlab.ca>,
 ibm-acpi-devel@lists.sourceforge.net, Randy Dunlap <rdunlap@xenotime.net>,
 linux-mtd@lists.infradead.org, Sekhar Nori <nsekhar@ti.com>,
 Daniel Walker <dwalker@fifo99.com>, lm-sensors@lm-sensors.org,
 Klaus Kudielka <klaus.kudielka@ieee.org>,
 Guenter Roeck <guenter.roeck@ericsson.com>, Kevin Hilman <khilman@ti.com>,
 linux-ia64@vger.kernel.org, Kukjin Kim <kgene.kim@samsung.com>,
 Russell King <linux@arm.linux.org.uk>, Samuel Ortiz <sameo@linux.intel.c
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20120329211131.GA31250@pengutronix.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mtd/>
List-Post: <mailto:linux-mtd@lists.infradead.org>
List-Help: <mailto:linux-mtd-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mtd>,
 <mailto:linux-mtd-request@lists.infradead.org?subject=subscribe>
Sender: linux-mtd-bounces@lists.infradead.org
Errors-To: linux-mtd-bounces+gldm-linux-mtd-36=gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, Mar 29, 2012 at 11:11:31PM +0200, Uwe Kleine-K=F6nig wrote:
> this series fixes a common error to use __initdata to mark const
> variables. Most of the time this works well enough to go unnoticed
> (though I wonder why the linker doesn't warn about that).
> Just try adding something like
> =

> 	int something __initdata;
> =

> to one of the patched files and compile to see the error.
> =

> While touching these annotations I also corrected the position where it
> was wrong to go between the variable name and the =3D.
> =

> Note this series is not compile tested.
I now dropped the wrong annotations. So two patches became obsolete
(mtd and percpu). Note that I also dropped fixing the position of
__initdata if changing it to __initconst was wrong. (I think if
__initdata is placed before the variable name it doesn't have any
effect.)

I didn't promote the Acks I got because all acked changes changed in v2.

For the details changed in each patch see the changelogs in the
respective patch mails that I follow up to this mail.

Thanks
Uwe

-- =

Pengutronix e.K.                           | Uwe Kleine-K=F6nig            |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

______________________________________________________
Linux MTD discussion mailing list
http://lists.infradead.org/mailman/listinfo/linux-mtd/
