From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC v2 2/4] staging: rtl8712: Change _LED_STATE enum in rtl871x
 driver to avoid conflicts with LED namespace
Date: Wed, 28 Sep 2016 11:27:41 +0200
Message-ID: <20160928092741.GA16646@kroah.com>
References: <1475013111-18942-1-git-send-email-zach.brown@ni.com>
 <1475013111-18942-3-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
 f.fainelli@gmail.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 mlindner@marvell.com, Larry.Finger@lwfinger.net
To: Zach Brown <zach.brown@ni.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1475013111-18942-3-git-send-email-zach.brown@ni.com>
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

On Tue, Sep 27, 2016 at 04:51:49PM -0500, Zach Brown wrote:
> Adding led support for phy causes namespace conflicts for some
> phy drivers.
> 
> The rtl871 driver declared an enum for representing LED states. The enum
> contains constant LED_OFF which conflicted with declaration found in
> linux/leds.h. LED_OFF changed to LED_STATE_OFF
> In order to avoid a possible future collision LED_ON was changed to
> LED_STATE_ON as well.
> 
> Signed-off-by: Zach Brown <zach.brown@ni.com>
> ---
>  drivers/staging/rtl8712/rtl8712_led.c | 388 +++++++++++++++++-----------------
>  1 file changed, 194 insertions(+), 194 deletions(-)

Ick, messy.  I'll be glad to take this patch now to make your life
easier in the future.

thanks,

greg k-h
