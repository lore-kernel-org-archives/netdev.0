From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: pass date and time info to NIC
 firmware
Date: Mon, 25 Sep 2017 20:27:23 -0700 (PDT)
Message-ID: <20170925.202723.162632379860934264.davem@davemloft.net>
References: <20170923003518.GA1583@felix-thinkpad.cavium.com>
        <20170923151654.GC21228@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: felix.manlunas@cavium.com, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, manish.awasthi@cavium.com,
        veerasenareddy.burru@cavium.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40460 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933685AbdIZD1Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 23:27:24 -0400
In-Reply-To: <20170923151654.GC21228@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sat, 23 Sep 2017 17:16:54 +0200

> On Fri, Sep 22, 2017 at 05:35:18PM -0700, Felix Manlunas wrote:
>> From: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>
> 
> This is kind of interesting. So you do this once. It could be before
> the RTC driver has probed, so it is 1970. It could be before the NTP
> daemon has started, and so the host clock will later jump, or stretch
> time to gain synchronisation.
> 
> It seems like you should be periodically giving the time to the
> firmware, not just once.

Specifically, you really need to send the time/date to the firmware
anytime the system time is updated.
