From: David Miller <davem@davemloft.net>
Subject: Re: selinux networking: sleeping functin called from invalid
 context in 2.6.20-rc[12]
Date: Tue, 02 Jan 2007 15:37:54 -0800 (PST)
Message-ID: <20070102.153754.08319614.davem@davemloft.net>
References: <20061224162511.eaac4a89.akpm@osdl.org>
	<20070102155826.A14811@freya>
	<200701021625.24694.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adam@yggdrasil.com, akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39380
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752334AbXABXhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jan 2007 18:37:54 -0500
To: paul.moore@hp.com
In-Reply-To: <200701021625.24694.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>
Date: Tue, 2 Jan 2007 16:25:24 -0500

> I'm sorry I just saw this mail (mail not sent directly to me get
> shuffled off to a folder).  I agree with your patch, I think
> dropping and then re-taking the RCU lock is the best way to go,
> although I'm curious to see what others have to say.

I think this is fine too.
