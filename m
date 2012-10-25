From: ratheesh kannoth <ratheesh.ksz@gmail.com>
Subject: dma_map_page and dma_map_single
Date: Thu, 25 Oct 2012 14:28:56 +0530
Message-ID: <CAGZFCEGLhEp7+sD98-HjQFwbkVo70M2OWh29Y+yG5xwbm82obw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:47029 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934838Ab2JYI64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 04:58:56 -0400
Received: by mail-oa0-f46.google.com with SMTP id h16so1352785oag.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 01:58:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi ,

I was looking at tx_map ( igb-3.3.6  ) in igb driver. I could see that
dma_map_single is used for first buffer and dma_map_page is used for
the fragments.

What is the real difference  between these api ?  we can replace
dma_map_single with dma_map_page. then  why  we used dma_map_single
here ?.

Thanks,
Ratheesh
