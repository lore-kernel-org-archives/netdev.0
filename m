From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next 3/6] net: Special routing hook
Date: Thu, 04 Jun 2015 09:40:01 +0200
Message-ID: <1433403601.1775100.286518937.543AE5E0@webmail.messagingengine.com>
References: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
 <1433361502-3478761-4-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	agartrell@fb.com, maheshb@google.com, tgraf@suug.ch,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:55582 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752223AbbFDHkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 03:40:02 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id CFCE420BC0
	for <netdev@vger.kernel.org>; Thu,  4 Jun 2015 03:40:01 -0400 (EDT)
In-Reply-To: <1433361502-3478761-4-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, Jun 3, 2015, at 21:58, Tom Herbert wrote:
> A hack to provide an ultra light weight hook to do translations.

Would it be possible to use ip6_ila_input hooks in dst_entry to do those
translations? It really seems like a hack ;)

Bye,
Hannes
