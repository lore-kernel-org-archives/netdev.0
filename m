From: David Miller <davem@davemloft.net>
Subject: Re: PF_RING: Include in main line kernel?
Date: Wed, 14 Oct 2009 14:49:23 -0700 (PDT)
Message-ID: <20091014.144923.112167161.davem@davemloft.net>
References: <8B385E10-4BE2-48A6-BDE0-0AA1A603275E@ntop.org>
	<20091014203640.GB32317@ioremap.net>
	<4AD64251.50903@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, deri@ntop.org, shemminger@vyatta.com,
	brad.doctor@gmail.com, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51902
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752728AbZJNVt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 17:49:26 -0400
In-Reply-To: <4AD64251.50903@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Wed, 14 Oct 2009 14:27:45 -0700

> Maybe something similar to the attached patch?

This is not something I'm interested in applying.

It makes implementing proprietary complete networking stacks
for Linux way too easy.

Instead I'd rather have a GPL exported function that allows indication
of consumption somehow.  That's why we have a special hook for
bonding, so it cannot be abused in proprietary modules.
