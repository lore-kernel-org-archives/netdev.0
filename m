From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: re: net/mlx4_core: Capping number of requested MSIXs to MAX_MSIX
Date: Sat, 29 Aug 2015 23:36:52 -0700
Message-ID: <CAJ3xEMhjt0PviFfSFn8iJY5J9ChiMsHTfbMbFKFEGW-WU87LoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>
To: Carol L Soto <clsoto@linux.vnet.ibm.com>,
	Matan Barak <matanb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:35096 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbbH3Ggx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2015 02:36:53 -0400
Received: by obbwr7 with SMTP id wr7so70168044obb.2
        for <netdev@vger.kernel.org>; Sat, 29 Aug 2015 23:36:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We currently manage IRQs in pool_bm which is a bit field of MAX_MSIX bits.
> Thus, allocating more than MAX_MSIX interrupts can't be managed in pool_bm.
> Fixing this by capping number of requested MSIXs to MAX_MSIX.

Carol, Matan, could U2 elaborate where/when the bug hits us?


Also, missing Fixes: line here with the offending commit ID so we can
realize if this needs to go into -stable

> Signed-off-by: Matan Barak <matanb@mellanox.com>
> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
