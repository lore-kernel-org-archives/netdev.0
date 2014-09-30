From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] et131x: Promote staging et131x driver to drivers/net
Date: Tue, 30 Sep 2014 12:32:01 -0700
Message-ID: <20140930193201.GA2349@kroah.com>
References: <1412104572-2931-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org, davem@davemloft.net,
 linux-kernel@vger.kernel.org
To: Mark Einon <mark.einon@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1412104572-2931-1-git-send-email-mark.einon@gmail.com>
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

On Tue, Sep 30, 2014 at 08:16:12PM +0100, Mark Einon wrote:
> This patch moves the et131x gigabit ethernet driver from drivers/staging
> to drivers/net/ethernet/agere.
> 
> Signed-off-by: Mark Einon <mark.einon@gmail.com>
> ---
> 
> This patch appiles to both staging-next and the linux-next tag next-20140930,
> and takes into account all feedback recieved from the recent RFC for this
> patch.
> 
>  MAINTAINERS                                        | 10 +++----
>  drivers/net/ethernet/Kconfig                       |  1 +
>  drivers/net/ethernet/Makefile                      |  1 +
>  drivers/net/ethernet/agere/Kconfig                 | 31 ++++++++++++++++++++++
>  .../et131x => net/ethernet/agere}/Makefile         |  0
>  .../et131x => net/ethernet/agere}/et131x.c         |  0
>  .../et131x => net/ethernet/agere}/et131x.h         |  0
>  drivers/staging/Kconfig                            |  2 --
>  drivers/staging/Makefile                           |  1 -
>  drivers/staging/et131x/Kconfig                     | 10 -------
>  drivers/staging/et131x/README                      | 15 -----------
>  11 files changed, 38 insertions(+), 33 deletions(-)
>  create mode 100644 drivers/net/ethernet/agere/Kconfig
>  rename drivers/{staging/et131x => net/ethernet/agere}/Makefile (100%)
>  rename drivers/{staging/et131x => net/ethernet/agere}/et131x.c (100%)
>  rename drivers/{staging/et131x => net/ethernet/agere}/et131x.h (100%)
>  delete mode 100644 drivers/staging/et131x/Kconfig
>  delete mode 100644 drivers/staging/et131x/README

This is a fine way to make a patch, but it's no way that any of the
netdev developers could ever review it to know what the code happens to
look like in my staging-next branch :(

How about just sending a patch that adds the driver to drivers/net/...
Don't worry about the staging driver at the moment.  If it gets added to
drivers/net we can then delete the staging driver.

Sound easier?  Should make the patches half as big.

thanks,

greg k-h
