From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] icmp6: Add new icmpv6 type for RPL control message
Date: Tue, 07 Oct 2014 01:53:46 +0200
Message-ID: <1412639626.712591.175897305.2FA01596@webmail.messagingengine.com>
References: <1412591826-32037-1-git-send-email-simon.vincent@xsilon.com>
 <20141006.181322.2253854250567400185.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, simon.vincent@xsilon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:46679 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751131AbaJFXxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 19:53:46 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by gateway2.nyi.internal (Postfix) with ESMTP id 56119205BF
	for <netdev@vger.kernel.org>; Mon,  6 Oct 2014 19:53:46 -0400 (EDT)
In-Reply-To: <20141006.181322.2253854250567400185.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, Oct 7, 2014, at 00:13, David Miller wrote:
> From: Simon Vincent <simon.vincent@xsilon.com>
> Date: Mon,  6 Oct 2014 11:37:06 +0100
> 
> > IANA has defined a type value of 155 for RPL control messages.
> > We do nothing if we recieve one of these messages. This patch is to
> > avoid getting lots of icmpv6 unknown type messages when using RPL.
> > 
> > Signed-off-by: Simon Vincent <simon.vincent@xsilon.com>
> 
> If we agree that pretty much our policy is that we treat as "known"
> any ICMPv6 type assigned officially by IANA, then we should simply
> add everything missing from the table at:
> 
> 	http://www.iana.org/assignments/icmpv6-parameters/icmpv6-parameters.xhtml
> 
> Any objections?

Might be possible, but I would favor to get rid of the printk or move
the test for informational icmp notifications up.
Some of the type < 128 icmp (non-informal) packets we also report to
user space, so we cannot just add them to a blacklist.

Bye,
Hannes
