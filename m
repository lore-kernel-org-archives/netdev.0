From: "devendra.aaru" <devendra.aaru@gmail.com>
Subject: Re: [PATCH] r6040: disable pci device if the subsequent calls (after
 pci_enable_device) fails
Date: Tue, 29 May 2012 15:43:26 +0530
Message-ID: <CAHdPZaM+UyaHv=HF0q1=qp7wTk_LXaF_+W8q5K-x+So5Bd0FSw@mail.gmail.com>
References: <1338206223-26781-1-git-send-email-devendra.aaru@gmail.com>
	<1659482.3g1Zl6FDuM@flexo>
	<CAHdPZaPWM3MfyARfwOm2KkKPPvm4dEfncF47N2xASyp27HdzsA@mail.gmail.com>
	<3646407.261CWqact8@flexo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3646407.261CWqact8@flexo>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

>> On Tue, May 29, 2012 at 2:50 PM, Florian Fainelli <florian@openwrt.o=
rg>
> wrote:
>
>>
>> Thanks for the Ack.
>> I found one more problem. Its when mdiobus_alloc fails in
>> r6040_init_one, we need to do call to the netif_napi_del and set the
>> NULL to pci_set_drvdata, at =A0err_out_unmap.
>
> Ok, can you please submit a patch to fix this issue as well? Thanks!
> --
Ok sure. will be doing it shortly.
> Florian

Thanks,
Devendra.
