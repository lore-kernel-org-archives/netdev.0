From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [PATCH] at86rf230: Allow slow GPIO pins for "rstn"
Date: Wed, 21 Dec 2016 22:01:15 +0100
Message-ID: <d1a4cfb5-9c0a-1bbe-1a5a-67f3f9e79d43@osg.samsung.com>
References: <1482103533-13187-1-git-send-email-andrew.smirnov@gmail.com>
 <7435a0a2-3f0f-a0db-9e0e-cb1ac838737c@osg.samsung.com>
 <CAFXsbZpgiTM2qngYERVpfXHvePW8M8DN91YnZwc-voKO=FDUUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Aring <aar@pengutronix.de>,
        Andrey Smirnov <andrew.smirnov@gmail.com>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wpan@vger.kernel.org
To: Chris Healy <cphealy@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFXsbZpgiTM2qngYERVpfXHvePW8M8DN91YnZwc-voKO=FDUUA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 21/12/16 19:30, Chris Healy wrote:
>
>
> On Dec 21, 2016 5:11 AM, "Stefan Schmidt" <stefan@osg.samsung.com
> <mailto:stefan@osg.samsung.com>> wrote:
>
>     Hello.
>
>
>     On 19/12/16 00:25, Andrey Smirnov wrote:
>
>         Driver code never touches "rstn" signal in atomic context, so
>         there's
>         no need to implicitly put such restriction on it by using
>         gpio_set_value
>         to manipulate it. Replace gpio_set_value to
>         gpio_set_value_cansleep to
>         fix that.
>
>
>     We need to make sure we are not assuming it can be called  in such a
>     context in the future now. But that is something we can worry about
>     if it comes up.
>
>
>         As a an example of where such restriction might be inconvenient,
>         consider a hardware design where "rstn" is connected to a pin of
>         I2C/SPI
>         GPIO expander chip.
>
>
>     Is this a real life issue you run into?
>
>
> I have a platform with this configuration.  The DTS for the platform is
> in the process of being mainlined right now.

Thanks for letting us know. What platform is that? I'm always interested 
in hearing about devices that use the Linux ieee802154 subsystem. :)

regards
Stefan Schmidt
