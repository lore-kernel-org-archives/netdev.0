From: David Miller <davem@davemloft.net>
Subject: Re: PF_RING: Include in main line kernel?
Date: Thu, 15 Oct 2009 00:22:21 -0700 (PDT)
Message-ID: <20091015.002221.141243865.davem@davemloft.net>
References: <4AD64251.50903@candelatech.com>
	<20091014.144923.112167161.davem@davemloft.net>
	<20091015070234.GA29506@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, deri@ntop.org, shemminger@vyatta.com,
	brad.doctor@gmail.com, netdev@vger.kernel.org
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44661
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751897AbZJOHWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 03:22:25 -0400
In-Reply-To: <20091015070234.GA29506@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Thu, 15 Oct 2009 11:02:34 +0400

> On Wed, Oct 14, 2009 at 02:49:23PM -0700, David Miller (davem@davemloft.net) wrote:
>> Instead I'd rather have a GPL exported function that allows indication
>> of consumption somehow.  That's why we have a special hook for
>> bonding, so it cannot be abused in proprietary modules.
> 
> I believe bonding with its hook is a historical heritage and priority
> absence in packet hooks which do not currently allow something to be
> registered very first and steal packets from the stack.

It is in same category as ingress packet scheduler hook.
