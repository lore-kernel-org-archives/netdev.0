From: <Bryan.Whitehead@microchip.com>
Subject: RE: [PATCH net-next 1/3] Add LAN743X driver
Date: Mon, 14 Aug 2017 16:15:29 +0000
Message-ID: <90A7E81AE28BAE4CBDDB3B35F187D264406F66D0@CHN-SV-EXMX02.mchp-main.com>
References: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
 <20170811160532.6a35b3b2@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <UNGLinuxDriver@microchip.com>
To: <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa1.microchip.iphmx.com ([68.232.147.91]:65322 "EHLO
        esa1.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751481AbdHNQQR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 12:16:17 -0400
In-Reply-To: <20170811160532.6a35b3b2@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> The statistics code here is confused.
> You are already counting rx_packets in software in napi_poll Then you get
> values from MAC. One or the other?
> There are two copies of stats, one in netdev and other in your mac structure.
> 
> Also what about byte and error counts?
> 
> If possible implement 64 bit get_stats64 instead.

Stephen,

Thanks for the feedback.

I will work on your suggestions, and submit again later.

Bryan
