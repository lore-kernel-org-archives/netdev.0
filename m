From: David Howells <dhowells@redhat.com>
Subject: (unknown)
Date: Tue, 14 Sep 2010 10:14:45 +0100
Message-ID: <28081.1284455685@redhat.com>
References: <cover.1284406638.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>, linux-fbdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
	James Smart <james.smart@emulex.com>, linux-mips@linux-mips.org, "VMware,
	Inc." <pv-drivers@vmware.com>, Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	alsa-devel@alsa-project.org, Jaroslav Kysela <perex@perex.cz>,
	dhowells@redhat.com, "James E.J. Bottomley" <James.Bottomley@suse.de>,
	Paul Mackerras <paulus@samba.org>, linux-i2c@vger.kernel.org,
	Brett Rudley <brudley@broadcom.com>, sparclinux@vger.kernel.org,
	devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
	e1000-devel@lists.sourceforge.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>, linux-acpi@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <cover.1284406638.git.joe@perches.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Sender: devel-bounces@linuxdriverproject.org
Errors-To: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> wrote:

> Using static const char foo[] = "bar" can save some
> code and text space, so change the places where it's possible.

That's reasonable.

> Also change the places that use
> 	char foo[] = "barX";
> 	...
> 	foo[3] = value + '0';
> where X is typically changed
> 	char foo[sizeof("barX")];
> 	...
> 	sprintf(foo, "bar%c", value + '0');

You haven't said what this gains.  I can see what it may cost, though
(depending on how gcc loads foo[]).

David
