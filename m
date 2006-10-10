From: "Jory A. Pratt" <anarchy@nctv.com>
Subject: bcm43xx scan oops!!!
Date: Mon, 09 Oct 2006 22:14:29 -0500
Message-ID: <452B1015.6040104@nctv.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxo6.broadbandsupport.net ([209.55.3.86]:51266 "EHLO
	mxo6.broadbandsupport.net") by vger.kernel.org with ESMTP
	id S964955AbWJJDS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 23:18:56 -0400
Received: from [192.168.1.100] (host-64-139-229-13.nctv.com [64.139.229.13])
	by mxo6.broadbandsupport.net (Postfix) with ESMTP id 62E772E0146
	for <netdev@vger.kernel.org>; Mon,  9 Oct 2006 23:14:34 -0400 (EDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(gdb) list *bcm43xx_dma_handle_xmitstatus+0xbd
0x3ad is in bcm43xx_dma_handle_xmitstatus (include/asm/dma-mapping.h:91).
86    static inline void
87    dma_unmap_single(struct device *dev, dma_addr_t addr,size_t size,
88             int direction)
89    {
90        BUG_ON(!valid_dma_direction(direction));
91        dma_ops->unmap_single(dev, addr, size, direction);
92    }
93    
94    #define dma_map_page(dev,page,offset,size,dir) \
95        dma_map_single((dev), page_address(page)+(offset), (size), (dir))


http://home.nctv.com/anarchy/dscape-clean.jpg

bcm43xx causes kernel oops on 4318 with latest wireless-dev git.

Jory


