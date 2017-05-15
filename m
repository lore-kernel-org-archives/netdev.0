From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: no address filtering on RNDIS
Date: Mon, 15 May 2017 10:16:58 -0400 (EDT)
Message-ID: <20170515.101658.471352019262168789.davem@davemloft.net>
References: <20170515115853.32688-1-oneukum@suse.com>
        <87efvqia63.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: oneukum@suse.com, netdev@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35244 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934424AbdEOORA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 10:17:00 -0400
In-Reply-To: <87efvqia63.fsf@miraculix.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bjørn Mork <bjorn@mork.no>
Date: Mon, 15 May 2017 14:20:20 +0200

> Oliver Neukum <oneukum@suse.com> writes:
> 
>> RNDIS does not do multicast filtering and the commands crash a few devices.
>> Make it conditional.
> 
> 
> Strange.  I thought we already discussed this when the filter reset
> request was initially added 3 years ago.  Ref
> https://patchwork.ozlabs.org/patch/374137/

I think the suggestion at the end of that thread is a better way to
handle this.
