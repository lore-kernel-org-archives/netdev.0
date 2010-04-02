From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH 1/2] phylib: Support phy module autoloading
Date: Fri, 2 Apr 2010 12:51:55 -0500
Message-ID: <o2k2acbd3e41004021051m75119350w2d5a372f5296a4a3@mail.gmail.com>
References: <20100401.193810.172601735.davem@davemloft.net>
	 <1270206327.3101.2436.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org, ben@decadent.org.uk
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:48257 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755896Ab0DBRv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 13:51:57 -0400
Received: by wwb17 with SMTP id 17so1502015wwb.19
        for <netdev@vger.kernel.org>; Fri, 02 Apr 2010 10:51:55 -0700 (PDT)
In-Reply-To: <1270206327.3101.2436.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 2, 2010 at 6:05 AM, David Woodhouse <dwmw2@infradead.org> wrote:
> We don't use the normal hotplug mechanism because it doesn't work. It will
> load the module some time after the device appears, but that's not good
> enough for us -- we need the driver loaded _immediately_ because otherwise
> the NIC driver may just abort and then the phy 'device' goes away.
>
> [bwh: s/phy/mdio/ in module alias, kerneldoc for struct mdio_device_id]
>
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Neat!

Acked-by: Andy Fleming <afleming@freescale.com>
