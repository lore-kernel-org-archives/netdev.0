From: Dave Jones <davej@redhat.com>
Subject: Re: FC5 iptables-restore failure
Date: Thu, 15 Feb 2007 06:20:22 -0500
Message-ID: <20070215112022.GD8353@redhat.com>
References: <20070215024507.8c97ee01.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:55683 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965650AbXBOLUa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 06:20:30 -0500
Content-Disposition: inline
In-Reply-To: <20070215024507.8c97ee01.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 15, 2007 at 02:45:07AM -0800, Andrew Morton wrote:
 > 
 > I've recently been noticing nasty messages come out of FC5:
 > 
 > sony:/home/akpm# service iptables stop
 > Flushing firewall rules:                                   [  OK  ]
 > Setting chains to policy ACCEPT: filter                    [  OK  ]
 > Unloading iptables modules:                                [  OK  ]
 > sony:/home/akpm# service iptables start
 > Applying iptables firewall rules: iptables-restore: line 20 failed
 >                                                            [FAILED]
 > 
 > Dunno when it started happening, but it's in mainline now.
 > 
 > It's a pretty stupid error message.  line 20 of what?

2.6.18 -> 2.6.19 changes a bunch of netfilter config option names.
Sure you weren't bitten by that ?

		Dave

-- 
http://www.codemonkey.org.uk
