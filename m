From: Fabio Estevam <festevam@gmail.com>
Subject: Re: commit-3ac72b7b63d5 breaks networking on iMX28
Date: Fri, 21 Oct 2016 11:43:49 -0200
Message-ID: <CAOMZO5DG6=pNDYgT4Bf4KBj4UPOwemBHNk6PYd8DZKt6Yp0PfQ@mail.gmail.com>
References: <bc6aa851-3f52-2274-47dc-4933662648a1@ginzinger.com> <fea86fa6-d74a-43ff-cf60-0d375336a5ba@nelint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Henri Roosen <henri.roosen@ginzinger.com>,
        Fugang Duan <fugang.duan@nxp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Nelson <eric@nelint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f41.google.com ([209.85.213.41]:33273 "EHLO
        mail-vk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755380AbcJUNnv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 09:43:51 -0400
Received: by mail-vk0-f41.google.com with SMTP id 83so116963126vkd.0
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 06:43:50 -0700 (PDT)
In-Reply-To: <fea86fa6-d74a-43ff-cf60-0d375336a5ba@nelint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Fri, Oct 21, 2016 at 11:39 AM, Eric Nelson <eric@nelint.com> wrote:

> Reading the i.MX28 reference manual, it appears that this SoC doesn't
> have the RACC bit, and I missed removal of the FEC_QUIRK_HAS_RACC flag.

On MX28 the register is called HW_ENET_MAC_IPACCRXCONF.

I sent a patch that fixes the issue.
