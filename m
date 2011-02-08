From: Hadmut Danisch <hadmut@danisch.de>
Subject: Re: [Bugme-new] [Bug 28282] New: forwarding turns autoconfiguration
 off
Date: Tue, 08 Feb 2011 23:12:30 +0100
Message-ID: <4D51BFCE.2070405@msgid.danisch.de>
References: <bug-28282-10286@https.bugzilla.kernel.org/>	<20110208133408.7d447e6a.akpm@linux-foundation.org> <20110208.134421.39185637.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sklave3.rackland.de ([212.86.200.186]:59025 "EHLO
	sklave3.rackland.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754574Ab1BHWTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 17:19:38 -0500
In-Reply-To: <20110208.134421.39185637.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.02.2011 22:44, David Miller wrote:
>
> This is a case where we're probably just following what the RFC documents
> state we should do, which means unless you can provide clear reference to
> a specification that states we should behave otherwise this isn't changing.

Could you cite where exactly this is stated in the RFC documents? (Would
save me the time to dig through all the RFCs to find that particular
statement and help avoid misunderstanding.)


It appears to me to be a contradiction in terms. IPv6 interfaces must be
able to have several IP addresses, and IPv6 does not have a default
route (or 0::0/0). IPv6 interfaces are designed to participate in
multiple independend logical networks (and several address ranges have
been reserved for future extensions and uses). It therefore does not
make sense if autoconfiguration for one network and routing for another
are mutually exclusive. I'd like to check this (and maybe file a bug in
the RFC).

regards
Hadmut

