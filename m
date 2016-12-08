From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/1] NET: usb: cdc_mbim: add quirk for supporting Telit
 LE922A
Date: Thu, 08 Dec 2016 13:02:48 -0500 (EST)
Message-ID: <20161208.130248.1105935880923968467.davem@davemloft.net>
References: <1481116068-32691-1-git-send-email-dnlplm@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: bjorn@mork.no, oliver@neukum.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org
To: dnlplm@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35764 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752510AbcLHSCu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 13:02:50 -0500
In-Reply-To: <1481116068-32691-1-git-send-email-dnlplm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniele Palmas <dnlplm@gmail.com>
Date: Wed,  7 Dec 2016 14:07:47 +0100

> Telit LE922A MBIM based composition does not work properly
> with altsetting toggle done in cdc_ncm_bind_common.
> 
> This patch adds CDC_MBIM_FLAG_AVOID_ALTSETTING_TOGGLE quirk
> to avoid this procedure that, instead, is mandatory for
> other modems.
> 
> References:
> https://www.spinics.net/lists/linux-usb/msg149249.html
> https://www.spinics.net/lists/linux-usb/msg149819.html
> 
> Thanks to Bjørn for the productive discussion and feedback!

Patch applied, thanks.
