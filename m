From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] SIOCGIFCOUNT implementation
Date: Mon, 23 Apr 2007 23:30:56 +0200
Message-ID: <200704232330.57086.ak@suse.de>
References: <200704211148.52705.ak@suse.de> <20070423141226.1c2127ce@localhost.localdomain> <20070423.142630.21932914.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33086 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753221AbXDWVbA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2007 17:31:00 -0400
In-Reply-To: <20070423.142630.21932914.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> Please also tell me what legacy application could actually
> use this thing when BSD itself doesn't even implement it?

Some version of java seems to. I see a lot of:

ioctl32(java:30851): Unknown cmd fd(3) cmd(00008938){00} arg(bfbb87c4) on socket:[334628709]

But just rejecting it is probably ok.

-Andi
