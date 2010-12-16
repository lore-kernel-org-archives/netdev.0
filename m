From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH V7 5/8] ptp: Added a brand new class driver for ptp clocks.
Date: Thu, 16 Dec 2010 16:57:23 +0100
Message-ID: <201012161657.24058.arnd@arndb.de>
References: <cover.1292512461.git.richard.cochran@omicron.at> <55b3188e735c3ce51608eef7926136d789182aa3.1292512461.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55b3188e735c3ce51608eef7926136d789182aa3.1292512461.git.richard.cochran@omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 16 December 2010, Richard Cochran wrote:
> This patch adds an infrastructure for hardware clocks that implement
> IEEE 1588, the Precision Time Protocol (PTP). A class driver offers a
> registration method to particular hardware clock drivers. Each clock is
> presented as a standard POSIX clock.
> 
> The ancillary clock features are exposed in two different ways, via
> the sysfs and by a character device.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

Looks fine to me, with one tiny comment:

> +
> +/* private globals */
> +
> +extern struct device_attribute ptp_dev_attrs[]; /* see ptp_sysfs.c */

The declaration is in a C file, better move it into a header in order
to make sure the definition matches the declaration.

	Arnd
