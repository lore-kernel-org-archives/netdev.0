From: Doug Anderson <dianders@chromium.org>
Subject: Re: [PATCH V2] r8152: add Linksys USB3GIGV1 id
Date: Thu, 28 Sep 2017 16:53:35 -0700
Message-ID: <CAD=FV=X=NGeuYhWhE95Zksmh-Q-geTChjsRXEmSkO-HmPOOm6Q@mail.gmail.com>
References: <20170926010925.114436-1-grundler@chromium.org>
 <CAD=FV=Uk=oPuF7LMhHPM_CTPNEa_G26R6Ce023pTNCCsyqts1Q@mail.gmail.com>
 <1506496556.28482.3.camel@suse.com> <CANEJEGtEfxR+8n3tRtsci=4Gtyhy021Z-DRvEgXPGFUqYK2u7Q@mail.gmail.com>
 <EE09EDA8-B6E9-4BEB-882C-C5435EDA8E41@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Grant Grundler <grundler@chromium.org>,
        Oliver Neukum <oneukum@suse.com>,
        "David S . Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Hayes Wang <hayeswang@realtek.com>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-usb <linux-usb@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:43222 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751713AbdI1Xxh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 19:53:37 -0400
Received: by mail-wr0-f170.google.com with SMTP id a43so5462816wrc.0
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 16:53:37 -0700 (PDT)
In-Reply-To: <EE09EDA8-B6E9-4BEB-882C-C5435EDA8E41@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, Sep 28, 2017 at 3:28 PM, Rustad, Mark D <mark.d.rustad@intel.com> wrote:
>
>> On Sep 27, 2017, at 9:39 AM, Grant Grundler <grundler@chromium.org> wrote:
>>
>> On Wed, Sep 27, 2017 at 12:15 AM, Oliver Neukum <oneukum@suse.com> wrote:
>>> Am Dienstag, den 26.09.2017, 08:19 -0700 schrieb Doug Anderson:
>>>>
>>>> I know that for at least some of the adapters in the CDC Ethernet
>>>> blacklist it was claimed that the CDC Ethernet support in the adapter
>>>> was kinda broken anyway so the blacklist made sense.  ...but for the
>>>> Linksys Gigabit adapter the CDC Ethernet driver seems to work OK, it's
>>>> just not quite as full featured / efficient as the R8152 driver.
>>>>
>>>> Is that not a concern?  I guess you could tell people in this
>>>> situation that they simply need to enable the R8152 driver to get
>>>> continued support for their Ethernet adapter?
>>>
>>> Hi,
>>>
>>> yes, it is a valid concern. An #ifdef will be needed.
>>
>> Good idea - I will post V3 shortly.
>>
>> I'm assuming you mean to add #ifdef CONFIG_USB_RTL8152 around the
>> blacklist entry in cdc_ether driver.
>
> Shouldn't that be an #if IS_ENABLED(...) test, since that seems to be the proper way to check configured drivers.

Yes, I had the same feedback on v3.  See my comments at
<https://patchwork.kernel.org/patch/9974485/>.  Grant has fixed it in
v4.  Please see <https://patchwork.kernel.org/patch/9976657/>.  :)

-Doug
