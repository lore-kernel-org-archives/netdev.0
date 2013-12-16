From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: Fw: [Bug 66691] New: iproute2: macvlan: Wrong root device shown
 if in different netns
Date: Mon, 16 Dec 2013 14:41:57 +0400
Message-ID: <52AED8F5.5030804@parallels.com>
References: <20131206120543.0afaafb5@nehalam.linuxnetplumber.net> <CAGXE3d81W+QG0kO_7P+36YkyNsRNup+MGq-1NQE0TxKMtBiJ4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Helmut Schaa <helmut.schaa@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:38300 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753622Ab3LPKmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 05:42:00 -0500
In-Reply-To: <CAGXE3d81W+QG0kO_7P+36YkyNsRNup+MGq-1NQE0TxKMtBiJ4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2013 02:38 PM, Helmut Schaa wrote:
> On Fri, Dec 6, 2013 at 9:05 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>> This isn't a iproute2 bug, it is only reporting what the kernel tells it
> 
> But iproute2 assumes that the ifindex is unique within all net
> namespaces. This isn't true anymore
> after commit aa79e66eee5d525e2fcbd2a5fcb87ae3dd4aa9e9 "net: Make
> ifindex generation
> per-net namespace".
> 
> However, in order to do the right thing iproute2 would have to know
> the ifindex of the
> link device _and_ its associated netns.
> 
> Not sure how to deal with that ...

Helmut, what would you expect to see from "ip netns exec myns ip link"
in case there were no device with ifindex 2 in the myns netns?

> Helmut
> .
> 
