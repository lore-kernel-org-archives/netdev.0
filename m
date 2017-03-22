From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ethoc: Use ether_addr_copy()
Date: Tue, 21 Mar 2017 17:17:12 -0700 (PDT)
Message-ID: <20170321.171712.1073677516696685013.davem@davemloft.net>
References: <20170317105215.2148-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        thierry.reding@gmail.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59026 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933573AbdCVARO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 20:17:14 -0400
In-Reply-To: <20170317105215.2148-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Fri, 17 Mar 2017 11:52:15 +0100

> Use ether_addr_copy() instead of memcpy() to set netdev->dev_addr (which
> is 2-byte aligned).
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
