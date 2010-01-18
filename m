From: greg@enjellic.com
Subject: Global IPV6 auto-configuration does not work as expected.
Date: Mon, 18 Jan 2010 13:06:06 -0600
Message-ID: <201001181906.o0IJ66mG028647@wind.enjellic.com>
Reply-To: greg@enjellic.com
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wind.enjellic.com ([209.243.13.15]:43449 "EHLO
	wind.enjellic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756027Ab0ARTX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 14:23:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Good afternoon, hope this note finds everyone's week starting well.

We are in the process of beginning full scale deployment of IPv6 and
have run into the following issue.  It is probably user error so feel
free to note it as such.

We want to turn off auto-configuration of IPv6 by our routers on all
interfaces on our servers.  From a bit of Googling and intuition we
assumed the following sysctl key would do this:

net.ipv6.conf.all.autoconf=0

But this seems to have no effect.  We have booted the machines and set
the above directive before the network configures and have also tried
setting the directive after boot followed by manual deletion of the
router assigned addresses but they keep returning.  It's happening
with 2.6.31.x and 2.6.32.x kernels.

The only way we have been able to disable the auto-configuration has
been to explicitly disable it at the individual interface level with
net.ipv6.conf.ethN.autoconf=0 directives.

We've noted the net.ipv6.conf.default.autoconf and experimented with
that a bit as well but haven't been able to accomplish our objective.

Thoughts?

Best wishes for a productive week.

As always,
Dr. G.W. Wettstein, Ph.D.   Enjellic Systems Development, LLC.
4206 N. 19th Ave.           Specializing in information infra-structure
Fargo, ND  58102            development.
PH: 701-281-1686
FAX: 701-281-3949           EMAIL: greg@enjellic.com
------------------------------------------------------------------------------
"Quidquid latine dictum sit, altum viditur."
        (Whatever is said in Latin, sounds profound.)
                                -- Kevin M Bealer
