From: Grant Grundler <grundler@chromium.org>
Subject: Re: [PATCH V2] r8152: add Linksys USB3GIGV1 id
Date: Wed, 27 Sep 2017 09:39:28 -0700
Message-ID: <CANEJEGtEfxR+8n3tRtsci=4Gtyhy021Z-DRvEgXPGFUqYK2u7Q@mail.gmail.com>
References: <20170926010925.114436-1-grundler@chromium.org>
 <CAD=FV=Uk=oPuF7LMhHPM_CTPNEa_G26R6Ce023pTNCCsyqts1Q@mail.gmail.com> <1506496556.28482.3.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Doug Anderson <dianders@chromium.org>,
        Grant Grundler <grundler@chromium.org>,
        "David S . Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Hayes Wang <hayeswang@realtek.com>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-usb <linux-usb@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506496556.28482.3.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2017 at 12:15 AM, Oliver Neukum <oneukum@suse.com> wrote:
> Am Dienstag, den 26.09.2017, 08:19 -0700 schrieb Doug Anderson:
>>
>> I know that for at least some of the adapters in the CDC Ethernet
>> blacklist it was claimed that the CDC Ethernet support in the adapter
>> was kinda broken anyway so the blacklist made sense.  ...but for the
>> Linksys Gigabit adapter the CDC Ethernet driver seems to work OK, it's
>> just not quite as full featured / efficient as the R8152 driver.
>>
>> Is that not a concern?  I guess you could tell people in this
>> situation that they simply need to enable the R8152 driver to get
>> continued support for their Ethernet adapter?
>
> Hi,
>
> yes, it is a valid concern. An #ifdef will be needed.

Good idea - I will post V3 shortly.

I'm assuming you mean to add #ifdef CONFIG_USB_RTL8152 around the
blacklist entry in cdc_ether driver.

cheers,
grant
