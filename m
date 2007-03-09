From: David Miller <davem@davemloft.net>
Subject: Re: IPV6: make ipv6_getsockopt_sticky honor user's buffer size
Date: Thu, 08 Mar 2007 17:11:50 -0800 (PST)
Message-ID: <20070308.171150.38709664.davem@davemloft.net>
References: <20070308071048.GD10574@sequoia.sous-sol.org>
	<20070308.143804.21927824.davem@davemloft.net>
	<20070309.094932.11513849.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: chrisw@sous-sol.org, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47075
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992855AbXCIBLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 20:11:50 -0500
In-Reply-To: <20070309.094932.11513849.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Fri, 09 Mar 2007 09:49:32 +0900 (JST)

> We should give truncated result and return full length
> from the POSIX POV.

True, and the user would know what happened because it
knows both the original length it gave and the larger
one the kernel gave as the return value.
