From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 3/4] inet: frags: use INET_FRAG_EVICTED to
 prevent icmp messages
Date: Thu, 31 Jul 2014 23:23:27 +0200
Message-ID: <20140731212327.GF23865@breakpoint.cc>
References: <1406819499-11198-1-git-send-email-nikolay@redhat.com>
 <1406819499-11198-4-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexander Aring <alex.aring@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:52866 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751120AbaGaVXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 17:23:32 -0400
Content-Disposition: inline
In-Reply-To: <1406819499-11198-4-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> Now that we have INET_FRAG_EVICTED we might as well use it to stop
> sending icmp messages in the "frag_expire" functions instead of
> stripping INET_FRAG_FIRST_IN from their flags when evicting.

Right, that makes sense.

Reviewed-by: Florian Westphal <fw@strlen.de>
