From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: allow ext learned entries to change
 ports
Date: Tue, 04 Jul 2017 01:54:51 -0700 (PDT)
Message-ID: <20170704.015451.1968696462580656207.davem@davemloft.net>
References: <1499120099-46428-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        jiri@resnulli.us, idosch@mellanox.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46438 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751960AbdGDIzA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 04:55:00 -0400
In-Reply-To: <1499120099-46428-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Mon,  3 Jul 2017 15:14:59 -0700

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> current code silently ignores change of port in the request
> message. This patch makes sure the port is modified and
> notification is sent to userspace.
> 
> Fixes: cf6b8e1eedff ("bridge: add API to notify bridge driver of learned FBD on offloaded device")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied.
