From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] net/pasemi: Fix missing coding style
Date: Sun, 24 Feb 2013 16:53:09 -0800
Message-ID: <CAOesGMh6WZDRz+kCgGME-EjKaxJWX3zrG8DD1wnGhHmbE1Z_LQ@mail.gmail.com>
References: <1361746879-29261-1-git-send-email-s.syam@samsung.com>
	<1361748185.2281.2.camel@joe-AO722>
	<1361748578.2281.6.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Syam Sidhardhan <syamsidhardh@gmail.com>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:61537 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759296Ab3BYAxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2013 19:53:12 -0500
Received: by mail-wi0-f169.google.com with SMTP id l13so4015423wie.0
        for <netdev@vger.kernel.org>; Sun, 24 Feb 2013 16:53:10 -0800 (PST)
In-Reply-To: <1361748578.2281.6.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 24, 2013 at 3:29 PM, Joe Perches <joe@perches.com> wrote:
> On Sun, 2013-02-24 at 15:23 -0800, Joe Perches wrote:
>> On Mon, 2013-02-25 at 04:31 +0530, Syam Sidhardhan wrote:
>> > Fix missing () & { }
>> []
>> > diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
>> []
>> > @@ -1829,10 +1831,11 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>> >             dev_err(&mac->pdev->dev, "register_netdev failed with error %d\n",
>> >                     err);
>> >             goto out;
>> > -   } else if netif_msg_probe(mac)
>> > +   } else if (netif_msg_probe(mac)) {
>> >             printk(KERN_INFO "%s: PA Semi %s: intf %d, hw addr %pM\n",
>> >                    dev->name, mac->type == MAC_TYPE_GMAC ? "GMAC" : "XAUI",
>> >                    mac->dma_if, dev->dev_addr);
>> > +   }
>> >
>> >     return err;
>> >
>>
>> Uncompilable since 2007!
>> That argues more for removal than anything else.

This driver is still used by several people running upstream kernels,
including myself. Removal is out of the question.

> Nevermind. Not true.
> netif_msg_probe is already surrounded by parens.
> It's just stylistic ugly.

Yeah, not sure how that one made it through way back then. Worth
fixing so it doesn't bite later if netif_msg_probe() is changed.


-Olof
