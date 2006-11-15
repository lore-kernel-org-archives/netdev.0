From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 1/2]: [NET]: Supporting UDP-Lite (RFC 3828) in Linux
Date: Tue, 14 Nov 2006 20:19:59 -0800 (PST)
Message-ID: <20061114.201959.112851807.davem@davemloft.net>
References: <200611140848.45863@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19936
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S966515AbWKOET7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 23:19:59 -0500
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200611140848.45863@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 14 Nov 2006 08:48:45 +0000

> [NET]:  Supporting UDP-Lite (RFC 3828) in Linux
> 
> This is a revision of the previously submitted patch, which alters
> the way files are organized and compiled in the following manner:
> 
> 	* UDP and UDP-Lite now use separate object files
> 	* source file dependencies resolved via header files
> 	  net/ipv{4,6}/udp_impl.h
> 	* order of inclusion files in udp.c/udplite.c adapted
> 	  accordingly

Looks excellent, applied to net-2.6.20, thanks Gerrit.
