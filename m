From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3] Set NTB format again after altsetting switch for
 Huawei devices
Date: Fri, 14 Jul 2017 08:15:19 -0700 (PDT)
Message-ID: <20170714.081519.1938487375638130917.davem@davemloft.net>
References: <20170711152152.30011-1-mrkiko.rs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: bjorn@mork.no, christian@panton.org, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, oliver@neukum.org
To: mrkiko.rs@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36186 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754424AbdGNPPV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 11:15:21 -0400
In-Reply-To: <20170711152152.30011-1-mrkiko.rs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Enrico Mioso <mrkiko.rs@gmail.com>
Date: Tue, 11 Jul 2017 17:21:52 +0200

> Some firmwares in Huawei E3372H devices have been observed to switch back
> to NTB 32-bit format after altsetting switch.
> This patch implements a driver flag to check for the device settings and
> set NTB format to 16-bit again if needed.
> The flag has been activated for devices controlled by the huawei_cdc_ncm.c
> driver.
> 
> V1->V2:
> - fixed broken error checks
> - some corrections to the commit message
> V2->V3:
> - variable name changes, to clarify what's happening
> - check (and possibly set) the NTB format later in the common bind code path
> 
> Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>
> Reported-and-tested-by: Christian Panton <christian@panton.org>
> Reviewed-by: Bjørn Mork <bjorn@mork.no>

Applied, thanks.
