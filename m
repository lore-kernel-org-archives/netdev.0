From: David Miller <davem@davemloft.net>
Subject: [PATCH v2 RFC 0/13] Remove UDP Fragmentation Offload support
Date: Fri, 07 Jul 2017 10:43:26 +0100 (WEST)
Message-ID: <20170707.104326.2165746493532974466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemdebruijn.kernel@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49770 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750778AbdGGJnb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 05:43:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is an RFC patch series, based upon some discussions with
various developers, that removes UFO offloading.

Very few devices support this operation, it's usefullness is
quesitonable at best, and it adds a non-trivial amount of
complexity to our data paths.

v2: Delete more code thanks to feedback from Willem.

Signed-off-by: David S. Miller <davem@davemloft.net>
