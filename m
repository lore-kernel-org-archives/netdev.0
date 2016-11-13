From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fixup packets with incorrect ethertype sent by ZTE
 MF821D
Date: Sun, 13 Nov 2016 12:00:15 -0500 (EST)
Message-ID: <20161113.120015.578328097660988615.davem@davemloft.net>
References: <20161113134753.GR2745@pokute.pelzi.net>
        <87zil3cq9i.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: plz@plz.fi, netdev@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43826 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751540AbcKMRAS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 12:00:18 -0500
In-Reply-To: <87zil3cq9i.fsf@miraculix.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bjørn Mork <bjorn@mork.no>
Date: Sun, 13 Nov 2016 17:12:57 +0100

> In any case, if we're going to add a fix like this, then I want it way
> more generic.  The only valid ethertypes expected from the modem is IP,
> IPV6 or ARP. Testing against those three, resetting anything else to IP,
> will at least catch *any* bogus value.
> 
> But I'm not convinced I want this additional processing of every packet
> just to let Qualcomm go on hiring monkeys-on-crack to write their
> firmware. At least not when we do have raw-ip as a workaround for the
> issue.
> 
> Feel free to try to convince me, though.

There are also several coding style problems with this patch.
