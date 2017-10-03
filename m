From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rndis_host: support Novatel Verizon USB730L
Date: Tue, 03 Oct 2017 14:31:31 -0700 (PDT)
Message-ID: <20171003.143131.650875825854523184.davem@davemloft.net>
References: <20170927213103.11987-1-aleksander@aleksander.es>
        <20171002.161750.1123671129875495210.davem@davemloft.net>
        <87k20cmitw.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: aleksander@aleksander.es, oliver@neukum.org,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53562 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751117AbdJCVbk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 17:31:40 -0400
In-Reply-To: <87k20cmitw.fsf@miraculix.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bjørn Mork <bjorn@mork.no>
Date: Tue, 03 Oct 2017 16:01:15 +0200

> We can pretty much ignore the USB-IF and any specs, since that is what
> the vendors appear to do.  They provide device specific drivers for
> Windows, so all they care about is that their device "works" with their
> driver.
> 
> But in Linux we prefer to create drivers for device classes whenever we
> can, to avoid having to add every single device by ID.  So we try to
> guess future patterns based on the devices we have observed, even when
> there is no clear spec.  This is what Aleksander does here. He has a
> device with a 'Cls=ef(misc ) Sub=04 Prot=01' function.  This device
> works with the rndis_host driver. That is all we know.
> 
> We cannot prove that a class match is correct. But it does make sense to
> try it.  At least we know that this works for one device.
> 
> Adding anything else, e.g. based on the table at
> http://www.usb.org/developers/defined_class/#BaseClassEFh , is a bit
> more risky.  We don't know if a driver will work with *any* such device
> until we've actually seen one.
> 
> This is just my opinion, and probably full of bogus assumptions as
> usual.  I was sort of hoping that some expert would speak up so I didn't
> have to :-)

Ok ;-)

> But FWIW:
> 
> Reviewed-by: Bjørn Mork <bjorn@mork.no>

So I'll apply this for now, thanks for your feedback.
