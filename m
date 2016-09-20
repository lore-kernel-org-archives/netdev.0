From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH v2 4/6] net: ethernet: bgmac: convert to feature flags
Date: Tue, 20 Sep 2016 09:59:24 -0400
Message-ID: <CAC3K-4rZGOeH8nw5jBFaJXKh3SDfv7qPicS7fby0u-f=Q7DigQ@mail.gmail.com>
References: <1467932938-21819-1-git-send-email-jon.mason@broadcom.com>
 <1467932938-21819-5-git-send-email-jon.mason@broadcom.com>
 <CACna6rw1j3myPEkbn+YR71W7CF7Of_yahn9eDT7t3hKWGmWUmg@mail.gmail.com> <CACna6rymVcKV1h_PEvRuCQrtOd4rsqV34bMWzVOof15fdc8KEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Hauke Mehrtens <hauke@hauke-m.de>,
        Rob Herring <robh+dt@kernel.org>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Kumar Gala <galak@codeaurora.org>, Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        bcm-kernel-feedback-list <bcm-kernel-feedback-list@broadcom.com>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACna6rymVcKV1h_PEvRuCQrtOd4rsqV34bMWzVOof15fdc8KEA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 20, 2016 at 1:19 AM, Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>=
 wrote:
> On 17 August 2016 at 13:34, Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> wr=
ote:
>> On 8 July 2016 at 01:08, Jon Mason <jon.mason@broadcom.com> wrote:
>>>         mode =3D (bgmac_read(bgmac, BGMAC_DEV_STATUS) & BGMAC_DS_MM_MAS=
K) >>
>>>                 BGMAC_DS_MM_SHIFT;
>>> -       if (ci->id !=3D BCMA_CHIP_ID_BCM47162 || mode !=3D 0)
>>> +       if (bgmac->feature_flags & BGMAC_FEAT_CLKCTLST || mode !=3D 0)
>>>                 bgmac_set(bgmac, BCMA_CLKCTLST, BCMA_CLKCTLST_FORCEHT);
>>> -       if (ci->id =3D=3D BCMA_CHIP_ID_BCM47162 && mode =3D=3D 2)
>>> +       if (bgmac->feature_flags & BGMAC_FEAT_CLKCTLST && mode =3D=3D 2=
)
>>>                 bcma_chipco_chipctl_maskset(&bgmac->core->bus->drv_cc, =
1, ~0,
>>>                                             BGMAC_CHIPCTL_1_RXC_DLL_BYP=
ASS);
>>
>> Jon, it looks to me you translated two following conditions:
>> ci->id !=3D BCMA_CHIP_ID_BCM47162
>> and
>> ci->id =3D=3D BCMA_CHIP_ID_BCM47162
>> into the same flag check:
>> bgmac->feature_flags & BGMAC_FEAT_CLKCTLST
>>
>> I don't think it's intentional, is it? Do you have a moment to fix this?
>
> Ping

Sorry, just seeing this now.  I'll double check the original code and
verify it (or fix it).

Thanks,
Jon

>
> --
> Rafa=C5=82
