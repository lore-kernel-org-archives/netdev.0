From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next v2] ipv6: sysctl to restrict candidate source
 addresses
Date: Fri, 10 Jul 2015 15:47:45 +0900
Message-ID: <559F6A91.7060502@miraclelinux.com>
References: <CAKD1Yr1RMjQ=VD=V4Vr4gdUDa6_ZT62SEdKBSUP3PogQMRYyUA@mail.gmail.com>	<1436345014.3846.11.camel@stressinduktion.org>	<CAAedzxqvEx+dMCmM5YLbnmd9REpcWFi=+nZ4s0EaBe8mxSKKgQ@mail.gmail.com> <20150708.144108.1074660115445698837.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: ek@google.com, hideaki.yoshifuji@miraclelinux.com,
	hannes@stressinduktion.org, lorenzo@google.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34709 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996AbbGJGrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 02:47:49 -0400
Received: by pabvl15 with SMTP id vl15so163273505pab.1
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 23:47:49 -0700 (PDT)
In-Reply-To: <20150708.144108.1074660115445698837.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

> So we should look at a way at making the new behavior the default, and
> in fact that makes sense and we can even optimize this piece of saddr
> selection code to not do an iteration over all devices in the system
> for no reason at all.  It can just do a quick dev_get_by_index() and
> work with that.
> 

I agree.  I've cooked up a patch for that optimization, so that Eric
can rebase his patch.

Regards,

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
