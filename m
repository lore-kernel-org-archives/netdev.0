From: David Miller <davem@davemloft.net>
Subject: Re: Fix net-2.6.22 on sparc
Date: Fri, 09 Mar 2007 17:00:55 -0800 (PST)
Message-ID: <20070309.170055.92583707.davem@davemloft.net>
References: <20070309.162404.99202412.davem@davemloft.net>
	<45F20230.8020204@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51432
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1767698AbXCJBA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 20:00:57 -0500
In-Reply-To: <45F20230.8020204@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 10 Mar 2007 01:56:16 +0100

> I just checked all arches and only sparc{64} have this strange
> SO_XXXX values not linear. I wonder why this layout was chosen ?

A lot of the API bogosity in the sparc userspace APIs comes from the
fact that we mirrored the SunOS values at the beginning of the port
and we're kind of stuck with that bad decision. :)
