From: Linus Walleij <linus.walleij@stericsson.com>
Subject: Re: [rtc-linux] [PATCH 00/20] world-writable files in sysfs and
	debugfs
Date: Fri, 4 Feb 2011 14:11:36 +0100
Message-ID: <AANLkTik9FkP==O7athEugN4gLrnh7qyg_pPRR3MZ0La7@mail.gmail.com>
References: <cover.1296818921.git.segoon@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Mike Christie <michaelc@cs.wisc.edu>,
	Srinidhi Kasagar <srinidhi.kasagar@stericsson.com>,
	Tony Lindgren <tony@atomide.com>, platform-driver-x86@vger.kernel.org,
	socketcan-core@lists.berlios.de, Corentin Chary <corentincj@iksaif.net>,
	"James E.J. Bottomley" <James.Bottomley@suse.de>,
	Julia Lawall <julia@diku.dk>, Russell King <linux@arm.linux.org.uk>,
	Samuel Ortiz <sameo@linux.intel.com>, linux-scsi@vger.kernel.org,
	Karol Kozimor <sziwan@users.sourceforge.net>,
	Kevin Hilman <khilman@deeprootsystems.com>,
	Luca Risolia <luca.risolia@studio.unibo.it>, open-iscsi@googlegroups.com,
	Wolfgang Grandegger <wg@grandegger.com>, Matthew Garrett <mjg@redhat.com>,
	acpi4asus-user@lists.sourceforge.net,
	Carlos Corbacho <carlos@strangeworlds.co.uk>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Alessandro Zummo <a.zummo@
To: rtc-linux@googlegroups.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <cover.1296818921.git.segoon@openwall.com>
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

2011/2/4 Vasiliy Kulikov <segoon@openwall.com>:

> The search was made with trivial shell commands:
>
> find | xargs grep S_IWUGO
> find | xargs grep S_IWOTH

We only use our debugfs entries as root so it shouldn't matter much, this
is way better, thanks for fixing.

> =A0mach-ux500: mbox-db5500: world-writable sysfs fifo file
> =A0mfd: ab3100: world-writable debugfs *_priv files
> =A0mfd: ab3500: world-writable debugfs register-* files
> =A0mfd: ab8500: world-writable debugfs register-* files

Acked-by: Linus Walleij <linus.walleij@stericsson.com>

For these.

Yours,
Linus Walleij
