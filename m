From: David Miller <davem@davemloft.net>
Subject: [PATCH RFC 0/12] Remove UDP Fragmentation Offload support
Date: Wed, 05 Jul 2017 16:04:02 +0100 (WEST)
Message-ID: <20170705.160402.80726683432003025.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42532 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750896AbdGEPEK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 11:04:10 -0400
Received: from localhost (unknown [193.136.225.129])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 9FA6E126C97E0
        for <netdev@vger.kernel.org>; Wed,  5 Jul 2017 08:04:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is an RFC patch series, based upon some discussions with
various developers, that removes UFO offloading.

Very few devices support this operation, it's usefullness is
quesitonable at best, and it adds a non-trivial amount of
complexity to our data paths.

Signed-off-by: David S. Miller <davem@davemloft.net>
