From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: iptables breakage on fc8 with recent kernels
Date: Mon, 3 Mar 2008 23:27:40 -0800
Message-ID: <20080303232740.42c3c3b9.akpm@linux-foundation.org>
References: <20080303214725.92ba0955.akpm@linux-foundation.org>
	<20080303.225549.191075913.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54878 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751695AbYCDH2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 02:28:16 -0500
In-Reply-To: <20080303.225549.191075913.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 Mar 2008 22:55:49 -0800 (PST) David Miller <davem@davemloft.net> wrote:

> > COMMIT
>  ...
> > So it is
> > 
> >    -A RH-Firewall-1-INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
> > 
> > which is now failing.
> > 
> > config: http://userweb.kernel.org/~akpm/config-t61p.txt
> 
> Please set CONFIG_NF_CONNTRACK.

ah, right, yup, thanks, I missed that.  I seem to have lost a great shower
of netfilter config options somewhere along the line.  I thought I'd
checked that :(

