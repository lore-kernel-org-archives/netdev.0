From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/12] bnxt_en: Add XDP support.
Date: Fri, 03 Feb 2017 15:49:10 -0500 (EST)
Message-ID: <20170203.154910.2213640966872850071.davem@davemloft.net>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51712 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752284AbdBCUt3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 15:49:29 -0500
In-Reply-To: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please _DO NOT_ guard XDP support with an ifdef the user
can modify.

Treat it like any other common netdev feature a driver might
support such as checksum offloading or GRO.

Thanks.
