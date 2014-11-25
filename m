From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Revert "netfilter: conntrack: fix race in
 __nf_conntrack_confirm against get_next_corpse"
Date: Tue, 25 Nov 2014 15:00:52 -0500 (EST)
Message-ID: <20141125.150052.718297541684545720.davem@davemloft.net>
References: <1416941687-25471-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	brouer@redhat.com
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1416941687-25471-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 25 Nov 2014 19:54:47 +0100

> This reverts commit 5195c14c8b27cc0b18220ddbf0e5ad3328a04187.
> 
> If the conntrack clashes with an existing one, it is left out of
> the unconfirmed list, thus, crashing when dropping the packet and
> releasing the conntrack since golden rule is that conntracks are
> always placed in any of the existing lists for traceability reasons.
> 
> Reported-by: Daniel Borkmann <dborkman@redhat.com>
> Fixes: https://bugzilla.kernel.org/show_bug.cgi?id=88841
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
> Hi David,
> 
> Could you manually apply this to your net tree? We have a better
> candidate fix to replace this broken patch that I will pass to you
> once it gets sufficient testing.

Done, thanks Pablo.
