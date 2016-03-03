From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/2] isdn: i4l: move active-isdn drivers to staging
Date: Thu, 3 Mar 2016 14:33:01 -0800
Message-ID: <20160303223301.GA19213@kroah.com>
References: <1456945629-1793533-1-git-send-email-arnd@arndb.de>
 <1456945629-1793533-2-git-send-email-arnd@arndb.de>
 <20160303.172222.338748622348351793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, isdn@linux-pingi.de, arnd@arndb.de,
 linux-doc@vger.kernel.org, netdev@vger.kernel.org, corbet@lwn.net,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20160303.172222.338748622348351793.davem@davemloft.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Thu, Mar 03, 2016 at 05:22:22PM -0500, David Miller wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Wed,  2 Mar 2016 20:06:46 +0100
> 
> > The icn, act2000 and pcbit drivers are all for very old hardware,
> > and it is highly unlikely that anyone is actually still using them
> > on modern kernels, if at all.
> > 
> > All three drivers apparently are for hardware that predates PCI
> > being the common connector, as they are ISA-only and active
> > PCI ISDN cards were widely available in the 1990s.
> > 
> > Looking through the git logs, it I cannot find any indication of a
> > patch to any of these drivers that has been tested on real hardware,
> > only cleanups or global API changes.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> Greg, can you please take these two patches?

will do
