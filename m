From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: linux-4.14-rc3/drivers/net/ieee802154/atusb.c:827: pointless test
 ?
Date: Thu, 19 Oct 2017 15:30:43 +0200
Message-ID: <ca44822a-4bc7-2ca8-42cf-b3937e5057d9@osg.samsung.com>
References: <HE1PR0802MB2331CD0AFCC839B844E961229C710@HE1PR0802MB2331.eurprd08.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: David Binderman <dcb314@hotmail.com>,
        "alex.aring@gmail.com" <alex.aring@gmail.com>,
        "linux-wpan@vger.kernel.org" <linux-wpan@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <HE1PR0802MB2331CD0AFCC839B844E961229C710@HE1PR0802MB2331.eurprd08.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

[Sorry for the delay, not really at my machine the last few weeks]

On 10/06/2017 09:06 PM, David Binderman wrote:
> Hello there,
> 
> linux-4.14-rc3/drivers/net/ieee802154/atusb.c:827]: (style) Unsigned variable 'fw_ver_maj' can't be negative so it is unnecessary to test it.
> 
> Source code is
> 
>     if (atusb->fw_ver_maj >= 0 && atusb->fw_ver_min >= 3)
> 
> but
> 
>     unsigned char fw_ver_maj;   /* Firmware major version number */
> 
> Suggest remove pointless test.

Thanks for pointing this out. Geert pointed the compiler warnign out a while ago and I actually did a fix that works for it already.

https://git.kernel.org/pub/scm/linux/kernel/git/sschmidt/wpan-next.git/commit/?id=763556980dde78166886734ae470664c67067dd4

Its waiting for getting pulled into net-next right now.

regards
Stefan Schmidt
