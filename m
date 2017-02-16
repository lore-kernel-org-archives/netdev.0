From: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
Subject: Re: RE: [PATCH net-next 11/13] net: ethernet: aquantia: Refactoring
 buffers copying.
Date: Thu, 16 Feb 2017 17:02:28 +0100
Message-ID: <trinity-c726d458-78f5-41bf-8d00-ac6d55a03c35-1487260948543@3capp-gmx-bs24>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
 <de4d3c34fac8c7bbbb614f776ca1255fd6aa03a6.1487187192.git.pavel.belous@aquantia.com>
 <4262ef98-4ba5-3f1a-5b72-208be51bdd6f@gmx.de>,
 <063D6719AE5E284EB5DD2968C1650D6DCFE68133@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Pavel Belous" <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Simon Edelhaus" <Simon.Edelhaus@aquantia.com>,
        "Alexey Andriyanov" <Alexey.Andriyanov@aquantia.com>
To: "David Laight" <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:53840 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754441AbdBPQCs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 11:02:48 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFE68133@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> ...
> > Well, you should really try to avoid copying the tx buffers _at all_.
> > E.g. by passing self->buff_ring to aq_ring_tx_append_buffs() instead of
> > the temporary array.
> 
> Copying can help for horridly fragmented frames or when iommu (etc)
> setup is expensive.
> At least some ethernet hardware has minimum fragment lengths.
> 

I was referring to the copy of tx descriptors, not the frames/fragments itself. 
I wrote "tx buffers" because in this driver a descriptor is represented as
 a struct "aq_ring_buff_s". I cannot see a reason why this descriptor copy
 should be necessary.
However I agree that there can be circumstances that would justify even the
copy of frame/fragment data.

Regards,
Lino
