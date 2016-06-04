From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: Provide CPU port statistics to master
 netdev
Date: Fri, 3 Jun 2016 17:06:28 -0700
Message-ID: <57521B84.1040800@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
 <1464998733-10405-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35155 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbcFDAGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 20:06:30 -0400
Received: by mail-pf0-f169.google.com with SMTP id g64so48313073pfb.2
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 17:06:30 -0700 (PDT)
In-Reply-To: <1464998733-10405-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2016 05:05 PM, Florian Fainelli wrote:
> This patch overloads the DSA master netdev, aka CPU Ethernet MAC to also
> include switch-side statistics, which is useful for debugging purposes,
> when the switch is not properly connected to the Ethernet MAC (duplex
> mismatch, (RG)MII electrical issues etc.).
> 
> We accomplish this by retaining the original copy of the master netdev's
> ethtool_ops, and just overload the 3 operations we care about:
> get_sset_count, get_strings and get_ethtool_stats so as to intercept
> these calls and call into the original master_netdev ethtool_ops, plus
> our own.
> 
> We take this approach as opposed to providing a set of DSA helper
> functions that would retrive the CPU port's statistics, because the
> entire purpose of DSA is to allow unmodified Ethernet MAC drivers to be
> used as CPU conduit interfaces, therefore, statistics overlay in such
> drivers would simply not scale.

Disregard this patch, it was left in the patches folder...
-- 
Florian
