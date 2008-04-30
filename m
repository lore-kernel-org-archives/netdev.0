From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net: ipv6 build fix
Date: Wed, 30 Apr 2008 14:48:35 -0700 (PDT)
Message-ID: <20080430.144835.25064746.davem@davemloft.net>
References: <20080430.013138.157977693.davem@davemloft.net>
	<20080430203839.GA19203@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53358
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758372AbYD3Vsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 17:48:36 -0400
In-Reply-To: <20080430203839.GA19203@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 30 Apr 2008 22:38:39 +0200

> 
> hi David,
> 
> * David Miller <davem@davemloft.net> wrote:
> 
> >       net: Several cleanups for the setsockopt compat support.
> >       net: Add compat support for getsockopt (MCAST_MSFILTER)
> 
> this broke !COMPAT builds in current -git. Fix below. NOTE: fix is just 
> a quick guess.

I know, Pavel posted a fix to netdev already which I'll push to
Linus.
