From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Use-after-free in TUNSETIFF
Date: Wed, 11 Sep 2013 15:44:07 +0100
Message-ID: <1378910647.1538.13.camel@bwh-desktop.uk.level5networks.com>
References: <522FACCB.1040707@epitech.eu> <522FB273.1030506@epitech.eu>
	 <20130910173257.47e2dc08@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wannes Rombouts <wannes.rombouts@epitech.eu>,
	<davem@davemloft.net>, <jasowang@redhat.com>, <mst@redhat.com>,
	<edumazet@google.com>, <nhorman@tuxdriver.com>,
	<netdev@vger.kernel.org>, Kevin Soules <kevin.soules@epitech.eu>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:45143 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754504Ab3IKOoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 10:44:12 -0400
In-Reply-To: <20130910173257.47e2dc08@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-10 at 17:32 -0700, Stephen Hemminger wrote:
[...]
> [1] A user with CAP_NET_ADMIN can basically hose the system many other ways.
> Capabilities are a failed security model.
> Almost all distro's limit CAP_NET_ADMIN to root anyway.

tun uses ns_capable(), not capable().  If user namespaces are enabled
then I think any user can create their own user & net namespaces, be
'root' in those namespaces and then invoke TUNSETIFF successfully.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
