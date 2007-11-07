From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: Why does a connect to IPv6 LLA address fail ?
Date: Wed, 7 Nov 2007 12:28:38 +0100
Message-ID: <20071107112838.GA22180@dhcp79.suse.cz>
References: <20071107094007.GA15575@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, kkeil@suse.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:54654 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751005AbXKGL2l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 06:28:41 -0500
Content-Disposition: inline
In-Reply-To: <20071107094007.GA15575@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> For this it create a socket for datagram and
> protocol IPPROTO_IP and then try to connect it with the destination
> address. This fails in the case of a LLA, because connect returns EINVAL,
> since here is no device bind to this socket at this time.

[snip]

> Why do we have this check in ip6_datagram_connect() ?

This problem has been nicely described in
http://www.linux-ipv6.org/ml/usagi-users/msg03062.html
without any response. 

RFC2461, Appendix A, really suggests performing neighbour
discovery on all the links. I like the idea, it would make LLAs
much more useful. 

Has anyone experimented with this? Is there any good reason why
we don't send NSs to all the links to find out which link the
destination LLA is on?

Regards,

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

