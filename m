From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: add automatic packet steering
 support
Date: Tue, 28 Mar 2017 22:20:46 -0700 (PDT)
Message-ID: <20170328.222046.99072127458018906.davem@davemloft.net>
References: <20170328194002.GA1066@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41872 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752531AbdC2FUs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 01:20:48 -0400
In-Reply-To: <20170328194002.GA1066@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Tue, 28 Mar 2017 12:40:02 -0700

> Packet steering can be enabled or disabled via ethtool like this:
> 
>     ethtool --set-priv-flags ethX pkt_steering on|off

Do not create private ethtool flags for something which is so fundamental.

We have the ethtool rxfh controls for this kind of thing already.
