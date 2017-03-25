From: Daniele Palmas <dnlplm@gmail.com>
Subject: Re: [PATCH 2/2] Documentation: ABI: testing: sysfs-class-net-qmi: add
 new qmap mux files description
Date: Sat, 25 Mar 2017 17:09:26 +0100
Message-ID: <CAGRyCJF_Gb55bdtV+Et_Rb5nMToFP+P1hQB0_GPgn6m=aSKpgQ@mail.gmail.com>
References: <1490361766-24114-1-git-send-email-dnlplm@gmail.com>
 <1490361766-24114-3-git-send-email-dnlplm@gmail.com> <8982c186-0560-a426-2873-bc21bc2f1765@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>,
        linux-usb <linux-usb@vger.kernel.org>, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34291 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751106AbdCYQJ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 12:09:28 -0400
In-Reply-To: <8982c186-0560-a426-2873-bc21bc2f1765@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

2017-03-24 17:31 GMT+01:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.=
com>:
> Hello!
>
>
> On 03/24/2017 04:22 PM, Daniele Palmas wrote:
>
>> This patch updates the documentation related to the new files added for
>> qmap mux support.
>>
>> Signed-off-by: Daniele Palmas <dnlplm@gmail.com>
>> ---
>>  Documentation/ABI/testing/sysfs-class-net-qmi | 27
>> +++++++++++++++++++++++++++
>>  1 file changed, 27 insertions(+)
>>
>> diff --git a/Documentation/ABI/testing/sysfs-class-net-qmi
>> b/Documentation/ABI/testing/sysfs-class-net-qmi
>> index fa5a00b..5191dc3 100644
>> --- a/Documentation/ABI/testing/sysfs-class-net-qmi
>> +++ b/Documentation/ABI/testing/sysfs-class-net-qmi
>> @@ -21,3 +21,30 @@ Description:
>>                 is responsible for coordination of driver and firmware
>>                 link framing mode, changing this setting to 'Y' if the
>>                 firmware is configured for 'raw-ip' mode.
>> +
>> +What:          /sys/class/net/<iface>/qmi/add_mux
>> +Date:          March 2017
>> +KernelVersion: 4.11
>> +Contact:       Bj=C3=B8rn Mork <bjorn@mork.no>
>> +Description:
>> +               Unsigned integer.
>> +
>> +               Write a number ranging from 1 to 127 to add a qmap mux
>> +               based network device, supported by recent Qualcomm based
>> +               modems.
>> +
>> +               The network device will be called qmimux.
>> +
>> +               Userspace is in charge of managing the qmux network devi=
ce
>> +               activation and data stream setup  on them modem side by
>
>
>    s/them/the/?
>

I will fix this if there will be a v2 series.

Thanks,
Daniele

>> +               using the proper QMI protocol requests.
>
> [...]
>
> MBR, Sergei
>
