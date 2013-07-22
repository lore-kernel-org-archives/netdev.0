From: Joe Perches <joe@perches.com>
Subject: Re: [Patch net-next 0/7] net: introduce generic type and helpers
 for IP address
Date: Mon, 22 Jul 2013 13:44:17 -0700
Message-ID: <1374525857.2061.57.camel@joe-AO722>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:36874 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755573Ab3GVUoS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 16:44:18 -0400
In-Reply-To: <1374476713-8838-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-22 at 15:05 +0800, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> As IPv6 becomes popular, more and more subsystems begin to support IPv6,
> therefore we need a generic IP address type, in case of duplicates.
> Also we will also need some helpers to compare, print, check the generic
> IP address.
> 
> This patchset introduce a new type union inet_addr as a union of IPv4
> and IPv6 address, and some helper functions that will be used by existing
> code and in the future VXLAN module.

I think this patchset is overly complicated.

I see no reason why vsprint's support for
"struct sockaddr *" %pIS should be removed.

%pIS and %pIA can both exist.
