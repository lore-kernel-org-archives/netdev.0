From: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 7/7] ARM: davinci: add support for the am1808 based
 enbw_cmc board
Date: Wed, 01 Feb 2012 14:20:13 +0400
Message-ID: <4F2911DD.6010405@mvista.com>
References: <1327308967-8092-1-git-send-email-hs@denx.de> <1327308967-8092-8-git-send-email-hs@denx.de> <20120130203252.GX28397@ponder.secretlab.ca> <4F27E6E0.1050608@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	Wolfgang Denk <wd-ynQEQJNshbs@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Ben Dooks <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>,
	David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: hs-ynQEQJNshbs@public.gmane.org
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F27E6E0.1050608-ynQEQJNshbs@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 31-01-2012 17:04, Heiko Schocher wrote:

>> On Mon, Jan 23, 2012 at 09:56:07AM +0100, Heiko Schocher wrote:
>>> - AM1808 based board
>>> - 64 MiB DDR ram
>>> - 2 MiB Nor flash
>>> - 128 MiB NAND flash
>>> - use internal RTC
>>> - I2C support
>>> - hwmon lm75 support
>>> - UBI/UBIFS support
>>> - MMC support
>>> - USB OTG support

>>> Signed-off-by: Heiko Schocher<hs-ynQEQJNshbs@public.gmane.org>
>>> Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
>>> Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
>>> Cc: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
>>> Cc: linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
>>> Cc: linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>> Cc: David Woodhouse<dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
>>> Cc: Ben Dooks<ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>
>>> Cc: Wolfram Sang<w.sang-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
>>> Cc: Sekhar Nori<nsekhar-l0cyMroinI0@public.gmane.org>
>>> Cc: Kevin Hilman<khilman-l0cyMroinI0@public.gmane.org>
>>> Cc: Wolfgang Denk<wd-ynQEQJNshbs@public.gmane.org>

>>> ---
>>> - post this board support with USB support, even though
>>>    USB is only working with the 10 ms "workaround", posted here:
>>>    http://comments.gmane.org/gmane.linux.usb.general/54505
>>>    I see this issue also on the AM1808 TMDXEXP1808L evalboard.
>>> - MMC and USB are not using OF support yet, ideas how to port
>>>    this are welcome. I need for USB and MMC boards board
>>>    specific callbacks, how to solve this with OF support?

[...]

>>> diff --git a/arch/arm/boot/dts/enbw_cmc.dts b/arch/arm/boot/dts/enbw_cmc.dts
>>> new file mode 100644
>>> index 0000000..e5995ce
>>> --- /dev/null
>>> +++ b/arch/arm/boot/dts/enbw_cmc.dts
[...]

>>> +			compatible = "ns16550a";

>> Should include a string for the specific device.  Something like:

>> 	compatible = "ti,da800", "ns16550a";

> added.

    Note that there's no DA800 chip, only DA828, DA830, and DA850 AFAIK.

WBR, Sergei
