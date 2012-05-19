From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.
Date: Fri, 18 May 2012 23:54:20 -0400 (EDT)
Message-ID: <20120518.235420.1669350688913610319.davem@davemloft.net>
References: <1337362769-4676-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alan@linux.intel.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966886Ab2ESDyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 23:54:22 -0400
In-Reply-To: <1337362769-4676-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri, 18 May 2012 13:39:29 -0400

> It was amusing that linux was able to make use of this 1980's
> technology on machines long past its intended lifespan, but
> it probably should go now -- it is causing issues in some
> distros[1], and while that might be fixable, it is just not
> worth it.
> 
> To set the context, the 3c501 was designed in the 1980's to be
> used on 8088 PC-XT 8bit ISA machines.  It was built using
> discrete TTL components and truly looks like a relic of the past.
> 
> But from a functional point of view, the real issue, as stated
> in the (also obsolete) Ethernet-HowTo, is that "...the 3c501 can
> only do one thing at a time -- while you are removing one packet
> from the single-packet buffer it cannot receive another packet,
> nor can it receive a packet while loading a transmit packet."
> 
> You know things are not good when the Kconfig help text suggests
> you make a cron job doing a ping every minute.
> 
> Hardware that old and crippled is simply not going to be used by
> anyone in a time where 10 year old 100Mbit PCI cards (that are
> still functional) are largely give-away items.
> 
> [1] http://www.linuxquestions.org/questions/linux-networking-3/3com-3c501-card-not-detecting-934344/
> 
> Cc: Alan Cox <alan@linux.intel.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Alan, any objections?
