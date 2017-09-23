From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] liquidio: pass date and time info to NIC
 firmware
Date: Sat, 23 Sep 2017 17:16:54 +0200
Message-ID: <20170923151654.GC21228@lunn.ch>
References: <20170923003518.GA1583@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, manish.awasthi@cavium.com,
        veerasenareddy.burru@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:53228 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750778AbdIWPQ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 23 Sep 2017 11:16:59 -0400
Content-Disposition: inline
In-Reply-To: <20170923003518.GA1583@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 22, 2017 at 05:35:18PM -0700, Felix Manlunas wrote:
> From: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>

This is kind of interesting. So you do this once. It could be before
the RTC driver has probed, so it is 1970. It could be before the NTP
daemon has started, and so the host clock will later jump, or stretch
time to gain synchronisation.

It seems like you should be periodically giving the time to the
firmware, not just once.

   Andrew
