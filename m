From: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Subject: Re: Firewall question
Date: Fri, 9 Jun 2006 09:12:17 -0400
Message-ID: <20060609131217.GJ558@csclub.uwaterloo.ca>
References: <20060608185712.79340.qmail@web50207.mail.yahoo.com> <20060608192628.GA561@csclub.uwaterloo.ca> <200606090543.24401.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alex Davis <alex14641@yahoo.com>, netfilter@lists.netfilter.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:34713 "EHLO
	caffeine.csclub.uwaterloo.ca") by vger.kernel.org with ESMTP
	id S965253AbWFINMU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 09:12:20 -0400
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <200606090543.24401.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 09, 2006 at 05:43:24AM +0200, Andi Kleen wrote:
> No one out on the internet, but it would be trivial for someone outside
> his house. All his traffic will be on a long unsecured cable. 
> 
> That is why I would never bridge home ethernet traffic onto a DSL line.

Hmm, traffic sent between his machines would not go over the DSL since
the MAC address doesn't match the DSL modem (I would think so at
least).  It would be a mess if the DSL modem tried to forwards all
traffic on an ethernet segment (well it doesn't have the bandwidth for
sure).  Maybe I am incorrectly assuming the DSL modem only forwards the
PPPoE traffic being sent at it.  I could see broadcast traffic being
forwarded, although arps and such are generally not that interesting.

Len Sorensen
