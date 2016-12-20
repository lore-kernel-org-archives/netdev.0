From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Tue, 20 Dec 2016 14:34:04 -0500
Message-ID: <20161220193404.epobyrdaghbrkijd@codemonkey.org.uk>
References: <20161220004013.43pcopemc6im32az@codemonkey.org.uk>
 <20161219.203623.119653805184192345.davem@davemloft.net>
 <20161220181728.dd2cynjwrceruwcu@codemonkey.org.uk>
 <20161220.132813.435056880928769245.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:37212 "EHLO
        arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938595AbcLTTeI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 14:34:08 -0500
Content-Disposition: inline
In-Reply-To: <20161220.132813.435056880928769245.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 20, 2016 at 01:28:13PM -0500, David Miller wrote:
 
 > This has to do with the SKB buffer layout and geometry, not whether
 > the packet is "fragmented" in the protocol sense.
 > 
 > So no, this isn't a criteria for packets being filtered out by this
 > point.
 > 
 > Can you try to capture what sk->sk_socket->type and
 > inet_sk(sk)->hdrincl are set to at the time of the crash?
 > 

type:3 hdrincl:0

	Dave
