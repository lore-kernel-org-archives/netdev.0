From: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Subject: Re: Firewall question
Date: Thu, 8 Jun 2006 15:26:28 -0400
Message-ID: <20060608192628.GA561@csclub.uwaterloo.ca>
References: <20060608185712.79340.qmail@web50207.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter@lists.netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:4287 "EHLO
	caffeine.csclub.uwaterloo.ca") by vger.kernel.org with ESMTP
	id S964853AbWFHT0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 15:26:31 -0400
To: Alex Davis <alex14641@yahoo.com>
Content-Disposition: inline
In-Reply-To: <20060608185712.79340.qmail@web50207.mail.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2006 at 11:57:12AM -0700, Alex Davis wrote:
> The scenario:
> I have a DSL modem in pass through (bridge) mode. The linux firewall/router 
> has a single ethernet card.  It is running pppoe. This gives two interfaces: 
> eth0 and ppp0. The firewall is running iptables. There are several machines 
> behind the firewall.
> 
> Problem:
> I've been told that if someone whose public IP address is on the same
> network subnet as mine were to get my mac address, (s)he could bypass
> the firewall and talk directly to the machines behind it.
> 
> Is this true?

Well the DSL modem only transfers whatever data the ISP end sends to it,
which in your case is just PPP packets (LCC or LCP I think).  No one out
on the internet would be able to send ethernet data over the DSL link,
so the only way to send data to another machine on your network (that
the DSL modem is connected to physically) is if you have other machines
on your local network which are also running PPPoE and listening for
that traffic.

So the worst thing I can see happening is that someone on your local
network could potentially take over your PPPoE session, but that's about
it.  I just can't see anything else that could happen.  I used to run
exactly the setup you describe before I had to drop the DSL connection
(I moved).

Len Sorensen
