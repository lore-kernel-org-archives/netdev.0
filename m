From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Fri, 25 Nov 2016 11:58:27 -0500 (EST)
Message-ID: <20161125.115827.2014848246966159357.davem@davemloft.net>
References: <ed0c9790-57be-8bca-cdd6-3a54ca24f0bd@pobox.com>
        <20161125095350.GA20653@kroah.com>
        <1816ec7e-2733-f4ba-5d30-29dbabd20aad@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, romieu@fr.zoreil.com, hayeswang@realtek.com,
        netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: mlord@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46586 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754244AbcKYRHH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 12:07:07 -0500
In-Reply-To: <1816ec7e-2733-f4ba-5d30-29dbabd20aad@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Lord <mlord@pobox.com>
Date: Fri, 25 Nov 2016 07:49:35 -0500

> On 16-11-25 04:53 AM, Greg KH wrote:
>> On Thu, Nov 24, 2016 at 10:49:33PM -0500, Mark Lord wrote:
>>> There is no possibility for them to be used for anything other than
>>> USB receive buffers, for this driver only.  Nothing in the driver
>>> or kernel ever writes to those buffers after initial allocation,
>>> and only the driver and USB host controller ever have pointers to the buffers.
>> 
>> You really are going to have to break out that USB monitor to verify
>> that this is the data coming across the wire.
> 
> Not sure why, because there really is no other way for the data to
> appear where it does at the beginning of that URB buffer.
> 
> This does seem a rather unexpected burden to place upon someone
> reporting a regression in a USB network driver that corrupts user data.

If you are the only person who can actively reproduce this, which
seems to be the case right now, this is unfortunately the only way to
reach a proper analysis and fix.
