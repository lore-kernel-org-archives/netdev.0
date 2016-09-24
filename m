From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] brcmfmac: fix memory leak in brcmf_fill_bss_param
Date: Sat, 24 Sep 2016 13:27:57 +0300
Message-ID: <87shsp1tjm.fsf@kamboji.qca.qualcomm.com>
References: <20160921062327.28729-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: =?utf-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <rafal@milecki.pl>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        "Franky \(Zhenhui\) Lin" <frankyl@broadcom.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: =?utf-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160921062327.28729-1-zajec5@gmail.com> (=?utf-8?Q?=22Rafa?=
 =?utf-8?Q?=C5=82_Mi=C5=82ecki=22's?=
        message of "Wed, 21 Sep 2016 08:23:24 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> writes:

> From: Rafa=C5=82 Mi=C5=82ecki <rafal@milecki.pl>
>
> This function is called from get_station callback which means that every
> time user space was getting/dumping station(s) we were leaking 2 KiB.
>
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <rafal@milecki.pl>
> Fixes: 1f0dc59a6de ("brcmfmac: rework .get_station() callback")
> Cc: stable@vger.kernel.org # 4.2+
> ---
> Kalle, ideally this should go as 4.8 fix, but I'm aware it's quite late.
> If you are not planning to send another pull request, just get it for
> the next release and let's let stable guys backport it.

An old memory leak is not severe enough for 4.8 at this stage, so I'll
queue this to 4.9.

BTW, either my Gnus or my SMTP server (I haven't bothered to check yet
why exactly) don't like the names with style of "(open list:NETWORKING
DRIVERS)" in the CC list, I have to edit them away everytime I reply.
Does anyone have any ideas why that's happening just to me?

--=20
Kalle Valo
