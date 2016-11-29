From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH net-next 1/1] driver: ipvlan: Add the sanity check for
 ipvlan mode
Date: Tue, 29 Nov 2016 09:06:44 +0800
Message-ID: <CA+6hz4qiUVLJDiF-sX8ckcMm-wq4=Z-3HGPCXXsAdqNbugzb5A@mail.gmail.com>
References: <1480339435-15551-1-git-send-email-fgao@ikuai8.com>
 <CAF2d9ji2_JhiNv9P9aUt7wV2Vfjv+z_q-MWSKKH8tzO_1THobg@mail.gmail.com> <20161128.150808.1499148970176655699.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:36145 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751432AbcK2BGq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 20:06:46 -0500
Received: by mail-ua0-f194.google.com with SMTP id 12so12201665uas.3
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 17:06:45 -0800 (PST)
In-Reply-To: <20161128.150808.1499148970176655699.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David & Mahesh,

On Tue, Nov 29, 2016 at 4:08 AM, David Miller <davem@davemloft.net> wrote:
> From: Mahesh Bandewar (=E0=A4=AE=E0=A4=B9=E0=A5=87=E0=A4=B6 =E0=A4=AC=E0=
=A4=82=E0=A4=A1=E0=A5=87=E0=A4=B5=E0=A4=BE=E0=A4=B0) <maheshb@google.com>
> Date: Mon, 28 Nov 2016 11:02:45 -0800
>
>> On Mon, Nov 28, 2016 at 5:23 AM, <fgao@ikuai8.com> wrote:
>>
>>> From: Gao Feng <fgao@ikuai8.com>
>>>
>>> The ipvlan mode variable "nval" is from userspace, so the ipvlan codes
>>> should check if the mode variable "nval" is valid.
>>>
>>> Signed-off-by: Gao Feng <fgao@ikuai8.com>
>>> ---
>>>  drivers/net/ipvlan/ipvlan_main.c | 3 +++
>>>  1 file changed, 3 insertions(+)
>>>
>>> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvl=
an_
>>> main.c
>>> index ab90b22..537b5a9 100644
>>> --- a/drivers/net/ipvlan/ipvlan_main.c
>>> +++ b/drivers/net/ipvlan/ipvlan_main.c
>>> @@ -65,6 +65,9 @@ static int ipvlan_set_port_mode(struct ipvl_port *por=
t,
>>> u16 nval)
>>>         struct net_device *mdev =3D port->dev;
>>>         int err =3D 0;
>>>
>>> +       if (nval >=3D IPVLAN_MODE_MAX)
>>> +               return -EINVAL;
>>> +
>>>
>> I'm curious to know how you encountered this issue? The values are
>> validated in ipvlan_nl_validate() and it should fail at that time itself=
.
>
> I'm not applying this without at least a better explanation.

Sorry, I didn't find the function "ipvlan_nl_validate" during reading
the ipvlan codes.

Regards
Feng
