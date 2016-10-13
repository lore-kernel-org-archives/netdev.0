From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netvsc: fix checksum on UDP IPV6
Date: Thu, 13 Oct 2016 10:48:54 -0400 (EDT)
Message-ID: <20161013.104854.161431794581843096.davem@davemloft.net>
References: <20161011140307.15fd390b@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33618 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752837AbcJMOs4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 10:48:56 -0400
In-Reply-To: <20161011140307.15fd390b@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 11 Oct 2016 14:03:07 -0700

> The software calculation of UDP checksum in Netvsc driver was
> only handling IPv4 case. By using skb_checksum_help() instead
> all protocols can be handled. Rearrange code to eliminate goto
> and look like other drivers.
> 
> This is a temporary solution; recent versions of Window Server etc
> do support UDP checksum offload, just need to do the appropriate negotiation
> with host to validate before using. This will be done in later patch.
> 
> Please queue this for -stable as well.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied and queued up for -stable, thanks Stephen.
