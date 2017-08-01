From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 0/2] liquidio: Add support for managing
 liquidio adapter
Date: Mon, 31 Jul 2017 17:59:37 -0700 (PDT)
Message-ID: <20170731.175937.1373949013417491840.davem@davemloft.net>
References: <20170729061707.GA1134@felix-thinkpad.cavium.com>
        <20170730202103.GA8969@vergenet.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: felix.manlunas@cavium.com, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, veerasenareddy.burru@cavium.com,
        jakub.kicinski@netronome.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48698 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751217AbdHAA7j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 20:59:39 -0400
In-Reply-To: <20170730202103.GA8969@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Sun, 30 Jul 2017 22:21:04 +0200

> On Fri, Jul 28, 2017 at 11:17:07PM -0700, Felix Manlunas wrote:
>> From: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>
>> 
>> The LiquidIO adapter has processor cores that can run Linux. This patch
>> set adds support to create a virtual Ethernet interface on host to
>> communicate with applications running on Linux in the LiquidIO adapter.
>> The virtual Ethernet interface also provides login access to Linux on
>> LiquidIO through ssh for management and debugging.
> 
> As per the somewhat more detailed feedback provided by my colleague Jakub
> Kicinski to v1 of this patchset[1] I am concerned that this patchset breaks down
> the long standing practice of not granting direct access to firmware from
> userspace.
> 
> [1] https://www.spinics.net/lists/netdev/msg444929.html

Agreed, I've seen no attempt to address this important feedback, which
I agree with.
