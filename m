From: Daniele Palmas <dnlplm@gmail.com>
Subject: Re: [PATCH 0/2] net: usb: qmi_wwan: add qmap mux protocol support
Date: Sat, 25 Mar 2017 17:05:16 +0100
Message-ID: <CAGRyCJG+-10Uj_4vrafvYmcj9Ram7qPJ6Yar_1CEfN8i5VsjqQ@mail.gmail.com>
References: <1490361766-24114-1-git-send-email-dnlplm@gmail.com> <f2c10991c8da27f209132efaebfce871@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>,
        linux-usb <linux-usb@vger.kernel.org>, netdev@vger.kernel.org,
        netdev-owner@vger.kernel.org
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f195.google.com ([74.125.82.195]:34599 "EHLO
        mail-ot0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751106AbdCYQLz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 12:11:55 -0400
In-Reply-To: <f2c10991c8da27f209132efaebfce871@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Subash,

2017-03-24 18:45 GMT+01:00 Subash Abhinov Kasiviswanathan
<subashab@codeaurora.org>:
> On 2017-03-24 07:22, Daniele Palmas wrote:
>>
>> This patch adds support for qmap mux protocol available in recent
>> Qualcomm based modems.
>>
>> The qmap mux protocol can be used for multiplexing data packets in
>> order to have multiple ip streams through the same physical device.
>>
>> Two new sysfs files are added for adding/removing the qmap mux based
>> interfaces (named qmimux):
>>
>> /sys/class/net/<iface>/qmi/add_mux
>> /sys/class/net/<iface>/qmi/del_mux
>>
>> Main patch author is Bj=C3=B8rn Mork <bjorn@mork.no>
>>
>> An userspace implementation of the qmi requests needed to support
>> multiple ip streams is already available (namely libqmi since
>> version 1.18.0).
>>
>> The qmap mux feature has been recently implemented in Codeaurora
>> gobinet out-of-kernel driver that was the inspiration for this
>> development.
>>
>> Tests have been performed with Telit LE922A6 (PID 0x1040)
>>
>> Daniele Palmas (2):
>>   net: usb: qmi_wwan: add qmap mux protocol support
>>   Documentation: ABI: testing: sysfs-class-net-qmi: add new qmap mux
>>     files description
>>
>>  Documentation/ABI/testing/sysfs-class-net-qmi |  27 +++
>>  drivers/net/usb/qmi_wwan.c                    | 317
>> +++++++++++++++++++++++++-
>>  2 files changed, 343 insertions(+), 1 deletion(-)
>
>
> Hi Daniele
>
> We are working on something similar
> https://www.mail-archive.com/netdev@vger.kernel.org/msg157677.html
>
> We are planning to upstream this as a platform agnostic driver without
> tying it to a particular physical transport here.
>
> We also add support for aggregation and flow control (control packet 0x80=
)
> apart from the multiplexing.
>

Thanks, I'll take a look at your patch series.

Regards,
Daniele

> --
> The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum=
,
> a Linux Foundation Collaborative Project
