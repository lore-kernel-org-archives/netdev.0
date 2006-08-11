From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 0/4]:  powerpc/cell spidernet ethernet driver fixes
Date: Fri, 11 Aug 2006 19:44:39 +0200
Message-ID: <20060811174439.GA30191@mars.ravnborg.org>
References: <20060811170337.GH10638@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, James K Lewis <jklewis@us.ibm.com>,
	Utz Bacher <utz.bacher@de.ibm.com>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932404AbWHKRpN@vger.kernel.org>
To: Linas Vepstas <linas@austin.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060811170337.GH10638@austin.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 11, 2006 at 12:03:37PM -0500, Linas Vepstas wrote:
> 
> The following series of patches implement some fixes and performance
> improvements for the Spedernet ethernet device driver. The high point
> of the patch series is some code to implement a low-watermark interrupt
> on the transmit queue. The bundle of patches raises transmit performance 
> from some embarassingly low value to a reasonable 730 Megabits per
> second for 1500 byte packets.
> 
> Please note that the spider is an ethernet controller that is 
> integrated into the south bridge, and is thus available only on
> Cell-based platforms.
> 
> These have been well-tested over the last few weeks. Please apply. 
Hi Linas.
Just noticed a nit-pick detail.
The general rule is to add your Signed-off-by: at the bottom of the
patch, so the top-most Signed-of-by: is also the original author whereas
the last Signed-of-by: is the one that added this patch to the kernel.
Likewise you add Cc: before your Signed-off-by: line.

See patches from for example Andrew Morton for examples.

	Sam
