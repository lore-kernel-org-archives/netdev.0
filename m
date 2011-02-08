From: Hadmut Danisch <hadmut@danisch.de>
Subject: Re: [Bugme-new] [Bug 28282] New: forwarding turns autoconfiguration
 off
Date: Tue, 08 Feb 2011 23:59:52 +0100
Message-ID: <4D51CAE8.6070706@msgid.danisch.de>
References: <20110208133408.7d447e6a.akpm@linux-foundation.org> <20110208.134421.39185637.davem@davemloft.net> <4D51BFCE.2070405@msgid.danisch.de> <20110208.143046.246534138.davem@davemloft.net> <20110208224411.GA9674@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sklave3.rackland.de ([212.86.200.186]:52505 "EHLO
	sklave3.rackland.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753802Ab1BHW7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 17:59:55 -0500
In-Reply-To: <20110208224411.GA9674@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.02.2011 23:44, Francois Romieu wrote:
>
> RFC 4862        IPv6 Stateless Address Autoconfiguration  September 2007
> [...]
>    The autoconfiguration process specified in this document applies only
>    to hosts and not routers.  Since host autoconfiguration uses
>    information advertised by routers, routers will need to be configured
>    by some other means.  However, it is expected that routers will
>    generate link-local addresses using the mechanism described in this
>    document.  In addition, routers are expected to successfully pass the
>    Duplicate Address Detection procedure described in this document on
>    all addresses prior to assigning them to an interface.

Thanks for the citation.


Since Linux machines can - in contrast to Windows desktops and cisco
routers - can be a host and a router at the same time, even on the same
interface (i.e. use a autoconf IPv6 address as a host and an fe80::
address as a router address).

So I'd consider this in a different way. From my point of view the
decision between host and router must be done per assigned IPv6 address
(or address range) and not per IPv6 interface.

(Maybe it would be a more correct implementation to assign a special IP
address pattern like  xxxx::.../64 to tell the interface to accept
autoconfiguration for a particular network range, probably  for 2::/3 in
most cases.)

regards
Hadmut


