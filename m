From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 2/3] [RFC] TCP syncookies: introduce sysctl to configure
 the MSS tables
Date: Fri, 16 Aug 2013 23:40:57 +0200
Message-ID: <20130816214057.GE5154@breakpoint.cc>
References: <520A3B4A.1050704@jakoblell.com>
 <20130815235743.GA25665@midget.suse.cz>
 <20130816000303.GB11950@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakob Lell <jakob@jakoblell.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34383 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751771Ab3HPWbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 18:31:47 -0400
Content-Disposition: inline
In-Reply-To: <20130816000303.GB11950@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac <jbohac@suse.cz> wrote:
> (compile-tested only)
> 
> This patch introduces two new sysctls
> 	net.ipv4.tcp_syncookies_mss_table
> 	net.ipv6.tcp_syncookies_mss_table
> to manipulate the TCP syncookie MSS tables

The cookie MSS table is small to begin with; trying
to find values that fit all possible clients is a losing game.

I cannot think of any scenarios where 2 machines, connected
to internet, could have different mss tables whilst _both_
improving the default values?
