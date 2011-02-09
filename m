From: Hadmut Danisch <hadmut@danisch.de>
Subject: Re: [Bugme-new] [Bug 28282] New: forwarding turns autoconfiguration
 off
Date: Wed, 09 Feb 2011 08:56:58 +0100
Message-ID: <4D5248CA.8090605@danisch.de>
References: <20110208133408.7d447e6a.akpm@linux-foundation.org> <20110208.134421.39185637.davem@davemloft.net> <4D51BFCE.2070405@msgid.danisch.de> <20110208.143046.246534138.davem@davemloft.net> <20110208224411.GA9674@electric-eye.fr.zoreil.com> <20110208234753.48abd902.billfink@mindspring.com> <20110209074221.GA9790@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Bill Fink <billfink@mindspring.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sklave3.rackland.de ([212.86.200.186]:52517 "EHLO
	sklave3.rackland.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752563Ab1BIH5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 02:57:02 -0500
In-Reply-To: <20110209074221.GA9790@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 09.02.2011 08:42, schrieb Francois Romieu:
>
> Why should we put our brains at pain ? Is there really a problem ?
>

Yep. It does not work.


I have a regular internet connection at home, as usual with dynamically
assigned IPv4 addresses. My router automatically creates an IPv6 tunnel,
so the IPv6 addresses are dynamic as well. German Internet providers
will offer IPv6 soon, and due to the german privacy requirements, they
will most probably offer dynamic IPv6 assignments as well. So a Linux
machine at home must accept autoconfiguration, if you do not want to
change your address manually at least once a day.

On the other hand, a regular Linux machine can have routing tasks. E.g.
when using a VPN, when dealing with virtual machines, for testing, for
TUN/TAP devices, and so on.

Although there is no good technical reason for not having both at the
same time, Linux does not allow this.

The machine's admin should at least have the choice to turn routing and
autoconf on and off independently.


regards
Hadmut

