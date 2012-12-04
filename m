From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next v2] bridge: implement multicast fast leave
Date: Tue, 4 Dec 2012 08:44:31 -0800
Message-ID: <20121204084431.72f9084c@nehalam.linuxnetplumber.net>
References: <1354615000-19660-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44673 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752146Ab2LDQpp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 11:45:45 -0500
In-Reply-To: <1354615000-19660-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  4 Dec 2012 17:56:40 +0800
Cong Wang <amwang@redhat.com> wrote:

> V2: make the toggle per-port
> 
> Fast leave allows bridge to immediately stops the multicast
> traffic on the port receives IGMP Leave when IGMP snooping is enabled,
> no timeouts are observed.
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Ok. as is.

A good followup change would be to migrate
these multicast flags into the existing flags bits (see hairpin etc),
and make them manageable via netlink.
