From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: vlan/macvlan 02/02: propagate transmission state to upper
 layers
Date: Tue, 10 Nov 2009 08:48:14 -0800
Message-ID: <20091110084814.02593603@nehalam>
References: <4AF99160.2060607@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47898 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756869AbZKJQsf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 11:48:35 -0500
In-Reply-To: <4AF99160.2060607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Nov 2009 17:14:24 +0100
Patrick McHardy <kaber@trash.net> wrote:

>   vlan/macvlan: propagate transmission state to upper layers
>     
>     Both vlan and macvlan devices usually don't use a qdisc and immediately
>     queue packets to the underlying device. Propagate transmission state of
>     the underlying device to the upper layers so they can react on congestion
>     and/or inform the sending process.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>


Bridging and bonding have same issue, but the solution is more difficult.
