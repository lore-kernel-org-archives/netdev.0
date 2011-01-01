From: Dan Carpenter <error27@gmail.com>
Subject: Re: [PATCH 03/15]drivers:staging:rtl8187se:r8180_hw.h Typo change
	diable to disable.
Date: Sat, 1 Jan 2011 12:09:31 +0300
Message-ID: <20110101090931.GH1886@bicker>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-2-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-3-git-send-email-justinmattock@gmail.com>
	<alpine.LNX.2.00.1012311722580.24460@nippy.intranet>
	<4D1EDB22.2020308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, trivial@kernel.org, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	Finn Thain <fthain@telegraphics.com.au>,
	linux-m68k@lists.linux-m68k.org, ivtv-devel@ivtvdriver.org,
	spi-devel-general@lists.sourceforge.net, linux-media@vger.kernel.org
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <4D1EDB22.2020308@gmail.com>
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

On Fri, Dec 31, 2010 at 11:43:30PM -0800, Justin P. Mattock wrote:
> On 12/31/2010 10:48 PM, Finn Thain wrote:
> >>-/*  BIT[8-9] is for SW Antenna Diversity. Only the value EEPROM_SW_AD_ENABLE means enable, other values are diable.					*/
> >>+/*  BIT[8-9] is for SW Antenna Diversity. Only the value EEPROM_SW_AD_ENABLE means enable, other values are disabled.					*/
> >
> >I think, "other values disable" was what you meant?
> >
> >Finn
> >
> >>  #define EEPROM_SW_AD_MASK			0x0300
> >>  #define EEPROM_SW_AD_ENABLE			0x0100
> >>
> >>
> >
> 
> no! I changed it to disabled to make it proper..

Finn is obviously right, but maybe a compromise would be:

Only the value EEPROM_SW_AD_ENABLE means "enable", other values mean
"disable".

regards,
dan carpenter
