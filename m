From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: no IPv6 Routers present
Date: Thu, 12 Mar 2009 19:17:37 -0400
Message-ID: <49B99811.6050304@hp.com>
References: <gpbtfk$s5h$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Markus Feldmann <feldmann_markus@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:37179 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754832AbZCLXRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 19:17:42 -0400
In-Reply-To: <gpbtfk$s5h$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Markus Feldmann wrote:
> Hi All,
> 
> i am working on a combined Firewall, means
> 2 Firewalls on one Personal Computer.
> 
> The first firewall is for my <ppp0> and
> the second firewall is for <eth0> if i connect
> through my Server to the internet.
> 
> However, if i plug off and plug in my network
> cable, to change the connection from <eth0> to
> <ppp0>, the connection to internet fails.
> From <ppp0> to <eth0> works, but than i can
> not switch back because of a unkown connection
> error.
> 
> <dmesg> prints out:
> no IPv6 Router present
> 

This is just an information message when it's trying to
configure IPv6.

> Ok maybe this is true. There is no IPv6 Router
> in my lan, but why do my Kernel not switch back
> to IPv4 ?

It didn't switch to IPv6 in the first place.  There is not switch.
The two work side-by-side.

If IPv4 is correctly configured it should continue to work.

> 
> How can i correct this ?
> I do not want to disable the whole IPv6 kernel/program
> options.

You can do this now in 2.6.29-rcXXX, but not before.  Also,
my bet is that something other then IPv6 is wrong here.

You need to give more information about your interface configurations,
routes, and any firewall rules.

-vlad

> 
> Is this a Bug ?
> 
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

