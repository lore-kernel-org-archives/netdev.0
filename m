From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: qlcnic: avoid superfluous assignement
Date: Sun, 31 Jul 2016 20:32:47 -0700 (PDT)
Message-ID: <20160731.203247.112564519224260656.davem@davemloft.net>
References: <1469959657-1342-1-git-send-email-xypron.glpk@gmx.de>
	<CAD=hENdsPG5u77N0vEnapSPmkJrLsPcXBUJ82s6msVX72sAi1g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xypron.glpk@gmx.de, Dept-GELinuxNICDev@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbcHADdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 23:33:37 -0400
In-Reply-To: <CAD=hENdsPG5u77N0vEnapSPmkJrLsPcXBUJ82s6msVX72sAi1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: zhuyj <zyjzyj2000@gmail.com>
Date: Mon, 1 Aug 2016 10:57:20 +0800

> Sorry.
> An inline function will be inserted into the calling function. Why
> "Assigning NULL to parmeter dcb has no effect outside of the
> inlined function." ?

It doesn't do anything to "dcb" in the calling function, that's not
how inlining works.

The inlined function behaves exactly as if it were called as a
non-inline function from the perspective of side effects visible to
the program.
