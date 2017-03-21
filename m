From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/11] net: usbnet: move to new api
 ethtool_{get|set}_link_ksettings
Date: Tue, 21 Mar 2017 16:04:34 -0700 (PDT)
Message-ID: <20170321.160434.1088351210921535166.davem@davemloft.net>
References: <1489702737-2401-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, jacmet@sunsite.dk,
        steve.glendinning@shawell.net, UNGLinuxDriver@microchip.com,
        gregkh@linuxfoundation.org, robert.foss@collabora.com,
        allan@asix.com.tw, grundler@google.com, jarod@redhat.com,
        peter.chen@nxp.com, stefan.bruens@rwth-aachen.de,
        akpm@linux-foundation.org, adobriyan@gmail.com,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58264 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756464AbdCUXG2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 19:06:28 -0400
In-Reply-To: <1489702737-2401-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Thu, 16 Mar 2017 23:18:46 +0100

> The ethtool api {get|set}_settings is deprecated. On usbnet, it
> was often implemented with usbnet_{get|set}_settings.
> 
> In this serie, I add usbnet_{get|set}_link_ksettings
> in the first patch, then I update all the driver to
> use this new api, and in the last patch I remove the
> old api usbnet_{get|set}_settings.

Series applied, thanks Philippe.
