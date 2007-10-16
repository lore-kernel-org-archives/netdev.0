From: Philip Craig <philipc@snapgear.com>
Subject: Re: [PATCH 0/2] Interface groups
Date: Tue, 16 Oct 2007 18:50:17 +1000
Message-ID: <47147B49.706@snapgear.com>
References: <1192521703479-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1192521703479-git-send-email-panther@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> Hello,
> 
> Different network interfaces can be grouped using the same group ID. With this
> patch fewer netfilter rules are necessary but it may also be used by routing.

This allows an interface to belong to only one group.  I expect there are
situations where you want more.  eg you might want a group of all pptp
connections, and another group of pptp connections for a subset of users.

An alternative approach would be to extend ipset to have sets of ifindex,
although this would tie it closer to iptables, and it would be slower.
But it still gives the properties of reducing the number of iptables rules,
and allowing to change group membership without reinstalling rules.

Maybe Jozsef has designed nfset to be able to handle this already?
