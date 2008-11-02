From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] xfrm6: handling fragment
Date: Sat, 01 Nov 2008 21:12:21 -0700 (PDT)
Message-ID: <20081101.211221.67297722.davem@davemloft.net>
References: <490B3DC9.906@dev.6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@dev.6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39783
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750823AbYKBEMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 00:12:45 -0400
In-Reply-To: <490B3DC9.906@dev.6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Date: Fri, 31 Oct 2008 18:18:01 +0100

> RFC4301 Section 7.1 says:
> 
> "7.1.  Tunnel Mode SAs that Carry Initial and Non-Initial Fragments
> 
>      All implementations MUST support tunnel mode SAs that are configured
>      to pass traffic without regard to port field (or ICMP type/code or
>      Mobility Header type) values.  If the SA will carry traffic for
>      specified protocols, the selector set for the SA MUST specify the
>      port fields (or ICMP type/code or Mobility Header type) as ANY.  An
>      SA defined in this fashion will carry all traffic including initial
>      and non-initial fragments for the indicated Local/Remote addresses
>      and specified Next Layer protocol(s)."
> 
> But for IPv6, fragment is treated as a protocol. Would the following patch be acceptable to catch protocol transported in fragmented packet?
> In IPv4, there is no problem.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

This seems good, I've applied this to net-next-2.6

Thanks.
