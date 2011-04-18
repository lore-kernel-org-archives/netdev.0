From: wangjun <wangjun.9322@gmail.com>
Subject: ixgbe: about ixgbe_clean_rx_irq
Date: Mon, 18 Apr 2011 23:51:43 +0800
Message-ID: <BANLkTi=6oxRQEkfytJLsWDEfsKVXY6NYcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:35174 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754442Ab1DRPvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 11:51:44 -0400
Received: by iyb14 with SMTP id 14so3982237iyb.19
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2011 08:51:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi:
     I  am  learning  the codes of  ixgbe-3.3.8,  and  i wonder why
the packet is invalid  in ixgbe_main.c:1645 ,
     and  if no RSC nor Packet Split  is  configured ,  we receive
larage packet that may span several descriptors and  buffers,  what
will the code do in this scene.

thanks !


1645    if (ixgbe_close_active_frag_list(skb) && !pkt_is_rsc) {
1646    /* if we got here without RSC the packet is invalid */
1647    dev_kfree_skb_any(skb);
1648    goto next_desc;
1649   }
