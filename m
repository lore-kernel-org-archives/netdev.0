From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH]: Fix for recently introduced rawv6 bug.
Date: Thu, 12 Jun 2008 23:05:53 +0100
Message-ID: <20080612220553.GJ28946@ZenIV.linux.org.uk>
References: <20080612.144933.184241072.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: den@openvz.org, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:38876 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752699AbYFLWFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 18:05:55 -0400
Content-Disposition: inline
In-Reply-To: <20080612.144933.184241072.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 12, 2008 at 02:49:33PM -0700, David Miller wrote:
> 
> Al Viro noticed that we have two assignments to
> rawv6_prot.destroy, fix below with more details in
> the commit message.
> 
> I'll commit this to net-2.6 and push to Linus.

ACK.  Why does ->destroy() return int, BTW?  All in-tree instances return 0
and AFAICS there's nothing caller could possibly do in case of error anyway...
