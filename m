From: ratheesh kannoth <ratheesh.ksz@gmail.com>
Subject: alloc_skb from huge memory
Date: Fri, 21 Mar 2014 10:21:36 +0530
Message-ID: <CAGZFCEHFBbHdc6ju2nh_smA++V4y4e_+LbLeaKVzRQtHwthGAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:38180 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbaCUEvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 00:51:36 -0400
Received: by mail-yh0-f46.google.com with SMTP id b6so1910402yha.33
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 21:51:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 alloc_skb  does allocation from slub.   memory  slab could be
kmalloc_1024 or kmalloc_512  (  And there is no  skb slab. i could not
find in  /proc/slabinfo ).

Is there any way  to allocate  skb from huge memory or    pre allocated pages ?


-Ratheesh
