From: Edward Cree <ecree@solarflare.com>
Subject: Re: ethtool NFC/ntuple API questions
Date: Wed, 20 Jan 2016 19:12:04 +0000
Message-ID: <569FDC04.9090509@solarflare.com>
References: <569FBF9D.40002@solarflare.com>
 <CAKgT0Ud1OprxqjYQC4NrFmRyhrG4x1G2=dWZEKwW866XAyW-eA@mail.gmail.com>
 <1453313223.3734.63.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:45646 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751194AbcATTMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 14:12:18 -0500
In-Reply-To: <1453313223.3734.63.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks both, it's making more sense now.
One thing I'm still unclear about: why does struct ethtool_usrip4_spechave
the ip_ver field?  The struct can't be extended to cover ipv6, because the
address fields aren't big enough.  So what's it for?

Also, would it be appropriate to use struct in6_addr for IPv6 addresses, or
should I use __be32[4]?

-Ed
