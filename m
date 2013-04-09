From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v3 3/4] vxlan: add ipv6 support
Date: Tue, 09 Apr 2013 18:47:26 +0800
Message-ID: <1365504446.2557.17.camel@cr0>
References: <1365387536-25217-1-git-send-email-amwang@redhat.com>
	 <1365387536-25217-3-git-send-email-amwang@redhat.com>
	 <OF82703BAC.20223779-ON85257B47.0040E058-85257B47.0046C8A6@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16987 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760339Ab3DIKri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 06:47:38 -0400
In-Reply-To: <OF82703BAC.20223779-ON85257B47.0040E058-85257B47.0046C8A6@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-08 at 08:53 -0400, David Stevens wrote:
>         With your current definitions, "sin6" is just an in6_addr, but
> you are not checking the sin6_scope_id, which is not correct for IPv6
> link-local addresses. You can rely on "ifindex" in vxlan_rdst for
> fdb entries, but you'd at least need to make sure it is not 0 for LL
> scope, and you still need sin6_scope_id to match for calls in 
> vxlan_snoop()
> and vxlan_group_used(). The same sin6_addr with different
> sin6_scope_id
> for link-local addrs is not the same address in v6. 

It seems this is not very easy to do, at least for me. So I will send
another patch after this patcheset is merged, now let's not make this to
be a blocker for this patchset.

Thanks!
