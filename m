From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: et131x: Fix errors caused by phydev->addr
 accesses before initialisation
Date: Sat, 9 Aug 2014 21:39:17 -0700
Message-ID: <20140810043917.GA17278@kroah.com>
References: <1407279426-8021-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Mark Einon <mark.einon@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1407279426-8021-1-git-send-email-mark.einon@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 05, 2014 at 11:57:06PM +0100, Mark Einon wrote:
> Fix two reported bugs, caused by et131x_adapter->phydev->addr being accessed
> before it is initialised, by:
> 
> - letting et131x_mii_write() take a phydev address, instead of using the one
>   stored in adapter by default. This is so et131x_mdio_write() can use it's own
>   addr value.
> - removing implementation of et131x_mdio_reset(), as it's not needed.
> - moving a call to et131x_disable_phy_coma() in et131x_pci_setup(), which uses
>   phydev->addr, until after the mdiobus has been registered.
> 
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=80751
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=77121
> Cc: stable@vger.kernel.org
> Signed-off-by: Mark Einon <mark.einon@gmail.com>
> ---
>  drivers/staging/et131x/et131x.c | 68 ++++++++++++++++-------------------------
>  1 file changed, 27 insertions(+), 41 deletions(-)

I got 3 copies of this patch, all look to be different?

I don't know what to do, so I've deleted them all, please resend the
version you want me to apply.

thanks,

greg k-h
