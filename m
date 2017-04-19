From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH v4] smsc95xx: Use skb_cow_head to deal with cloned skbs
Date: Wed, 19 Apr 2017 14:36:16 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40A4998A@CHN-SV-EXMX02.mchp-main.com>
References: <20170419101340.27929-1-james.hughes@raspberrypi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <steve.glendinning@shawell.net>, <UNGLinuxDriver@microchip.com>
To: <james.hughes@raspberrypi.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa1.microchip.iphmx.com ([68.232.147.91]:52293 "EHLO
        esa1.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934849AbdDSOgS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 10:36:18 -0400
In-Reply-To: <20170419101340.27929-1-james.hughes@raspberrypi.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The driver was failing to check that the SKB wasn't cloned
> before adding checksum data.
> Replace existing handling to extend/copy the header buffer
> with skb_cow_head.
> 
> Signed-off-by: James Hughes <james.hughes@raspberrypi.org>
> ---

Acked-by: Woojung Huh <Woojung.Huh@microchip.com>
