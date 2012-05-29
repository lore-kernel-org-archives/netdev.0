From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] r6040: disable pci device if the subsequent calls (after pci_enable_device) fails
Date: Tue, 29 May 2012 12:06:29 +0200
Message-ID: <3646407.261CWqact8@flexo>
References: <1338206223-26781-1-git-send-email-devendra.aaru@gmail.com> <1659482.3g1Zl6FDuM@flexo> <CAHdPZaPWM3MfyARfwOm2KkKPPvm4dEfncF47N2xASyp27HdzsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "devendra.aaru" <devendra.aaru@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHdPZaPWM3MfyARfwOm2KkKPPvm4dEfncF47N2xASyp27HdzsA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 29 May 2012 15:28:51 devendra.aaru wrote:
> Hello Florian,
> 
> On Tue, May 29, 2012 at 2:50 PM, Florian Fainelli <florian@openwrt.org> 
wrote:

> 
> Thanks for the Ack.
> I found one more problem. Its when mdiobus_alloc fails in
> r6040_init_one, we need to do call to the netif_napi_del and set the
> NULL to pci_set_drvdata, at  err_out_unmap.

Ok, can you please submit a patch to fix this issue as well? Thanks!
--
Florian
