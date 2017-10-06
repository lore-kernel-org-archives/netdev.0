From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 1/3] tun: ethtool stats
Date: Sat, 07 Oct 2017 00:26:42 +0100 (WEST)
Message-ID: <20171007.002642.1079626333365040708.davem@davemloft.net>
References: <20171006153059.193688a5@xeon-e3>
        <CAF=yD-JZnJ4v3KZY2O3yBKWNnLxRBZJcJDVkYNuHYUZHX5Yw-Q@mail.gmail.com>
        <20171006161245.0f4abb99@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemdebruijn.kernel@gmail.com, netdev@vger.kernel.org,
        mst@redhat.com, jasowang@redhat.com, willemb@google.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49624 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752278AbdJFX0z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 19:26:55 -0400
In-Reply-To: <20171006161245.0f4abb99@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 6 Oct 2017 16:12:45 -0700

> On Fri, 6 Oct 2017 18:37:01 -0400
> Willem de Bruijn <willemdebruijn.kernel@gmail.com> wrote:
> 
>> > It looks like you are just exporting the statistics taht are already
>> > through normal path. The purpose of ethtool stats is to provide
>> > statistics unique to the device, not to repeat what is available throug
>> > ip, ifconfig, etc.  
>> 
>> A follow-up patch adds non-standard statistics.
>> 
>> I included these common ones, because the new zerocopy counters
>> are only interesting in relation to tx_packets.
>> 
>> It also seems customary among existing network drivers to include
>> at least these base counters in the ethtool output.
> 
> Only some drivers that slipped through before I started noticing.
> Do Not Repeat.

Agreed, that is a bad practice unless it is being done to export
per-queue versions of those standard netdev statistics.
