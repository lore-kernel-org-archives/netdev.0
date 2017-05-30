From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next 0/9] mlxsw: Support firmware flash
Date: Tue, 30 May 2017 23:32:22 +0300
Message-ID: <CAJ3xEMi_U-139_EXfuT+d0PLyBOn6C+aWaGpFfmH6E8odhtvaw@mail.gmail.com>
References: <ea7cf005-1f6c-aa87-db90-03d7c77c7d56@mellanox.com>
 <BLUPR0701MB2004EB2F32B4C8C42C5020458DF90@BLUPR0701MB2004.namprd07.prod.outlook.com>
 <fba5a440-ba1e-84bd-d2d2-d011406d3a4a@mellanox.com> <20170523.113859.1803057381093280239.davem@davemloft.net>
 <0daa5c5a-377c-767f-ea19-26c1f22bd30c@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>, Yuval.Mintz@cavium.com,
        Jiri Pirko <jiri@resnulli.us>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Ido Schimmel <idosch@mellanox.com>, mlxsw <mlxsw@mellanox.com>,
        bhutchings@solarflare.com
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:35459 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750811AbdE3UcX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 16:32:23 -0400
Received: by mail-oi0-f48.google.com with SMTP id l18so126380318oig.2
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 13:32:23 -0700 (PDT)
In-Reply-To: <0daa5c5a-377c-767f-ea19-26c1f22bd30c@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 28, 2017 at 10:26 AM, Yotam Gigi <yotamg@mellanox.com> wrote:
> On 05/23/2017 06:38 PM, David Miller wrote:
>> From: Yotam Gigi <yotamg@mellanox.com>
>> Date: Tue, 23 May 2017 18:14:15 +0300

>>> Sorry, I am not sure I understand. You think that drivers should not implement
>>> ethtool's flash_device callback anymore? do you have an alternative for
>>> firmware flash?

>> As stated, export an MTD device.

> So, after we have been going over MTD, it seems like it does not fit our needs
> at all.

> MTD device provides (erasable-)block access to a flash storage, where in our
> case the firmware burn process is just pouring a binary BLOB into the device.
> The driver is not aware of the internal storage used for storing the firmware as
> it is not defined in our driver-hardware API.
>
> Needless to say that block access has no meaning in our case, so any solution
> that will involve MTD device to burn our firmware (if there is a solution at
> all) will be a workaround and will not fit MTD purpose.
>
> Apart for boot time firmware flash, which we have already pushed we would really
> like to allow the user to ask for a specific firmware version. Do you have any
> other solution for us apart from "ethtool -f"?
>
> This problem is even more relevant in the Mellanox HCA driver team, which would
> like to use that code in order to burn the HCA firmware, but not intend to
> trigger it on boot time, which means that must have a way for the user to
> trigger it.


Hi Dave,

We had few more emails on this thread with Jakub, and he's now happy
with our replies, so where do we go from here? could you comment on
Yotam's note.

thanks,

Or.
