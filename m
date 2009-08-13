From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: Use correct NET_RX_* returns for atalk_rcv()
Date: Thu, 13 Aug 2009 19:00:27 +0930
Message-ID: <20090813190027.c9cff7c7.lk-netdev@lk-netdev.nosense.org>
References: <20090807185122.30f022de.lk-netdev@lk-netdev.nosense.org>
	<20090812.221550.173145055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.adam.net.au ([202.136.110.249]:42909 "EHLO
	smtp3.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753769AbZHMJae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 05:30:34 -0400
In-Reply-To: <20090812.221550.173145055.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Aug 2009 22:15:50 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
> Date: Fri, 7 Aug 2009 18:51:22 +0930
> 
> > 
> >     In all rx'd SKB cases, atalk_rcv() either eventually jumps to or falls through
> >     to the label out:, which  returns numeric 0. Numeric 0 corresponds to
> >     NET_RX_SUCCESS, which is incorrect in failed SKB cases.
> >     
> >     This patch makes atalk_rcv() provide the correct returns by:
> >     
> >     o  explicitly returning NET_RX_SUCCESS in the two success cases
> >     o  having the out: label return NET_RX_DROP, instead of numeric 0
> >     o  making the failed SKB labels and processing more consistent with other
> >        _rcv() routines in the kernel, simplifying validation and removing a
> >        backwards goto
> > 
> > Signed-off-by: Mark Smith <markzzzsmith@yahoo.com.au>
> 
> Applied.

Thanks David.
