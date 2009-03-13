From: feldmaus <feldmann_markus@gmx.de>
Subject: Re: no IPv6 Routers present
Date: Fri, 13 Mar 2009 08:36:16 +0000 (UTC)
Message-ID: <loom.20090313T082825-818@post.gmane.org>
References: <gpbtfk$s5h$1@ger.gmane.org> <49B99811.6050304@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:60443 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678AbZCMIgh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 04:36:37 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Li2sc-0001cW-Q4
	for netdev@vger.kernel.org; Fri, 13 Mar 2009 08:36:34 +0000
Received: from dslb-092-076-224-011.pools.arcor-ip.net ([92.76.224.11])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 08:36:34 +0000
Received: from feldmann_markus by dslb-092-076-224-011.pools.arcor-ip.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2009 08:36:34 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich <vladislav.yasevich <at> hp.com> writes:

> You need to give more information about your interface configurations,
> routes, and any firewall rules.
Next Bug, but this one should refer to the kernel i think:
This one works not. --> <http://nopaste.debianforum.de/19665>

But this one works not --> <http://nopaste.debianforum.de/19664>

I worked out the syslog messages and the differences:
In the not working configuration i used <NOARP> for eth0.
I don't know why, but i think it come from ppp0 which
uses it:
########################################################################
iface dsl-provider inet ppp
    pre-up /sbin/ifconfig eth0 up -arp 0 # line maintained by pppoeconf
    provider dsl-provider
########################################################################

I also got some syslog Messages, this are for you:
########################################################################
[  775.402699] host used greatest stack depth: 5672 bytes left
########################################################################

And i ran my <firewalllan> manually, so i got the following:
########################################################################
iptables: Resource temporarily unavailable
iptables: Resource temporarily unavailable
iptables: Too many links
iptables: Resource temporarily unavailable
iptables: Too many links
########################################################################

I think this all comes from NOARP ?

Any Idea ?

Regards Markus

