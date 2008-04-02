From: David Miller <davem@davemloft.net>
Subject: Re: [PING^2] [PATCH] srandom32 fixes for networking
Date: Wed, 02 Apr 2008 01:03:24 -0700 (PDT)
Message-ID: <20080402.010324.121433616.davem@davemloft.net>
References: <20080401113408.GA625@basil.nowhere.org>
	<20080402.001824.161259886.davem@davemloft.net>
	<20080402075011.GL29105@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50580
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754423AbYDBIDY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 04:03:24 -0400
In-Reply-To: <20080402075011.GL29105@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 2 Apr 2008 09:50:11 +0200

> Can you send me your config please? I don't see any build problem
> here with the patch on top of -rc7-git something on either i386 nor x86-64.

I found it with "git grep srandom32", I guess I'm quite old school in
that I actually check the tree when interfaces are being changed.

Even if this code is not built into the tree somehow, knowingly
breaking code like this is not very nice.

It does seem to get built with CONFIG_CPA_DEBUG, which
is available from arch/x86/Kconfig.debug
