From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 2/4] inet: frags: rename last_in to flags, enum
 the definitions and add comments
Date: Thu, 31 Jul 2014 23:26:15 +0200
Message-ID: <20140731212615.GG23865@breakpoint.cc>
References: <1406819499-11198-1-git-send-email-nikolay@redhat.com>
 <1406819499-11198-3-git-send-email-nikolay@redhat.com>
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
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:52883 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753168AbaGaV0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 17:26:16 -0400
Content-Disposition: inline
In-Reply-To: <1406819499-11198-3-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> The last_in field has been used to store various flags different from
> first/last frag in so give it a more descriptive name: flags. Move
> the flags to an enum definion, swap FIRST_IN/LAST_IN to be in logical
> order and add comments explaining each flag, also add comments explaining
> the inet_frag_queue struct members. While at it align some function
> declarations.

Acked-by: Florian Westphal <fw@strlen.de>
