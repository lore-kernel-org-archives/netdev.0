From: David Miller <davem@davemloft.net>
Subject: Re: NAPI on USB network drivers
Date: Wed, 25 Jan 2017 14:32:26 -0500 (EST)
Message-ID: <20170125.143226.525018584694503090.davem@davemloft.net>
References: <1485336881.16604.2.camel@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org
To: oneukum@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32838 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750768AbdAYTc2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 14:32:28 -0500
In-Reply-To: <1485336881.16604.2.camel@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.com>
Date: Wed, 25 Jan 2017 10:34:41 +0100

> looking at r8152 I noticed that it uses NAPI. I never considered
> this for the generic USB networking code as you cannot disable
> interrupts for USB. Is it still worth it? What are the benefits?

I think it's not a good approach for getting GRO.

Exactly because of the issue you raise, in that USB drivers
cannot stop the URBs from coming in while running their poll
method.
