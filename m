From: "Keyur Chudgar" <kchudgar.linux@gmail.com>
Subject: Single packet receiving in multiple ring buffers
Date: Wed, 21 May 2008 18:35:18 -0700
Message-ID: <a967d7d00805211835q241f8edai6253659330b8e6cf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:39087 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758462AbYEVBfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 21:35:30 -0400
Received: by yw-out-2324.google.com with SMTP id 9so1830422ywe.1
        for <netdev@vger.kernel.org>; Wed, 21 May 2008 18:35:20 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a question regarding packets received in multiple ring buffers
from hw interface,
if the packet size is larger than the ring buffer size.

The way generally I saw this is done is,
1. Initially allocate skb with MTU size and configure ring buffer
2. If packet comes in multiple ring buffers, they copy these buffers
and make a new single
skb out of it
3. Send a single skb to netif_rx

The point 2 above can be done either using memcpy or DMA. But in any
case, we need a copy.

Does anybody know, if there is a way, we can avoid the copy operation
while a single packet
received in multiple ring buffers?

Thanks,
- Keyur
