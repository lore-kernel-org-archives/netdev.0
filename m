From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 5/5] qede: Split PF/VF ndos.
Date: Wed, 17 May 2017 11:10:07 -0400 (EDT)
Message-ID: <20170517.111007.1089356716021925537.davem@davemloft.net>
References: <1494331671-16273-1-git-send-email-Yuval.Mintz@cavium.com>
        <1494331671-16273-6-git-send-email-Yuval.Mintz@cavium.com>
        <CY1PR0701MB20094B9857D89E463608F3B98DE70@CY1PR0701MB2009.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33674 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752832AbdEQPKQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 11:10:16 -0400
In-Reply-To: <CY1PR0701MB20094B9857D89E463608F3B98DE70@CY1PR0701MB2009.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Wed, 17 May 2017 06:16:46 +0000

> Looking at my alternatives for solving this, I can't see any 'good'
> options - it seems mightily unorthodox to modify net_device_ops,
> I.e., add/remove an NDO function-pointer based on some device
> property, and having multiple ops declared for the sake of a single
> feature seems unscalable.

Multiple ops is the only thing that works right now.
