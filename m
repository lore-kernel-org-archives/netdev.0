From: Javier Domingo <javierdo1@gmail.com>
Subject: DMA allocation driver defined limit?
Date: Wed, 24 Apr 2013 20:18:12 +0200
Message-ID: <CALZVapkJZotCxzMbGhZfvVV3G8W2z5tehEe7BaTjps620M+-Mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:46730 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756188Ab3DXSSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 14:18:33 -0400
Received: by mail-vc0-f182.google.com with SMTP id ht11so2082689vcb.41
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 11:18:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying to find how big can the DMA memory be, as I haven't found
anything in the docs that describes exactly a general size of DMA
allocation, I have supposed that it depends entirely on the card.

As a general approach, is it alright to suppose that the DMA memory
will be as big as the internal memory of the network card?

The real question here is, when using DMA, the driver has a limit of
packet size or a limit of sk_buffs it can receive? For me is like
there should be a size limit (althought I suppose there can't be
unlimited skbuffs).

Thanks for your attention and looking back for a replay,

Javier Domingo
