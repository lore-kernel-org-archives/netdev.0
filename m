From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Fri, 14 Jan 2011 14:49:45 +0800
Message-ID: <AANLkTikP1T9XXPVNHnmPnamjwyF5nNn+hVvpovAxTx69@mail.gmail.com>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com> <1294959948.4114.189.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294959948.4114.189.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Joe,

On Fri, Jan 14, 2011 at 7:05 AM, Joe Perches <joe@perches.com> wrote:
> On Thu, 2011-01-13 at 19:49 +0800, Po-Yu Chuang wrote:
>> From: Po-Yu Chuang <ratbert@faraday-tech.com>
> []
>> + =C2=A0 =C2=A0 if (is_zero_ether_addr(netdev->dev_addr)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 random_ether_addr(netdev=
->dev_addr);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dev_info(&netdev->dev, "=
generated random MAC address "
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 "%.2x:%.2x:%.2x:%.2x:%.2x:%.2x.\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 netdev->dev_addr[0], netdev->dev_addr[1],
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 netdev->dev_addr[2], netdev->dev_addr[3],
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 netdev->dev_addr[4], netdev->dev_addr[5]);
>
> Sorry, one other thing.
> There are kernel specific printf extensions for pointer types.
> (look at lib/vsprintf.c) =C2=A0There's one for mac addresses: "%pM".
> This could be done as:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev_info(ne=
tdev, "Generated random MAC address: %pM\n",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0netdev->dev_addr);

Wow, this is pretty beautiful. Thanks.

best regards,
Po-Yu Chuang
