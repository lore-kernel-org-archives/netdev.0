From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] r8152: fix the rx settings of RTL8153
Date: Wed, 22 Mar 2017 10:52:57 -0700 (PDT)
Message-ID: <20170322.105257.1084620999883432568.davem@davemloft.net>
References: <1394712342-15778-256-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42176 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935791AbdCVRxE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 13:53:04 -0400
In-Reply-To: <1394712342-15778-256-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Mon, 20 Mar 2017 16:13:43 +0800

> The RMS and the rx early size should base on the same rx size. However,
> the RMS is set to 9K bytes now and the rx early depends on mtu. For using
> the rx buffer effectively, sync the two settings according to the mtu.

Series applied.
