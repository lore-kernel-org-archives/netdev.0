From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v3] net: macb: Added PCI wrapper for Platform Driver.
Date: Wed, 21 Dec 2016 14:22:28 +0200
Message-ID: <CAHp75Vf7VBWVWE-jcM0bv9t7QSnpAG46izpkDpqx7VaSdPgUCw@mail.gmail.com>
References: <1481648560-25927-1-git-send-email-bfolta@cadence.com>
 <SN1PR0701MB19516D29452ABA2695B2F061CC9A0@SN1PR0701MB1951.namprd07.prod.outlook.com>
 <CAHp75VeOcAsTDsYDuQ_2nG1RUWn-txuHBJqyJnY-ywvPfeiK6g@mail.gmail.com>
 <SN1PR0701MB19517F15DBF69C2666FD67FACC930@SN1PR0701MB1951.namprd07.prod.outlook.com>
 <CAHp75VcD8uCoiXiMV2f7OrPUDysGQX_VFZM+9+1pzRSNkT883Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Simon Horman <simon.horman@netronome.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Rafal Ozieblo <rafalo@cadence.com>
To: Bartosz Folta <bfolta@cadence.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75VcD8uCoiXiMV2f7OrPUDysGQX_VFZM+9+1pzRSNkT883Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2016 at 2:16 PM, Andy Shevchenko
<andy.shevchenko@gmail.com> wrote:
> On Wed, Dec 21, 2016 at 1:53 PM, Bartosz Folta <bfolta@cadence.com> wrote:

>> I think that there is a delay on some mailing lists (marc.info and
>> mail-archive.com). Latest messages I found there are from December
>> 16th 2016.
>
> You may refer to
> https://www.spinics.net/lists/netdev/msg410864.html

And one more

+       plat_info.dma_mask = DMA_BIT_MASK(32);

Perhaps
 plat_info.dma_mask = pdev->dma_mask;
?

-- 
With Best Regards,
Andy Shevchenko
