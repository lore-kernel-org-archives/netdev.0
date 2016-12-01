From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [flamebait] xdp, well meaning but pointless
Date: Thu, 1 Dec 2016 18:20:36 +0100
Message-ID: <f1eef5a5-023e-4edb-ce9e-53a94821044c@stressinduktion.org>
References: <20161201091108.GF26507@breakpoint.cc>
 <20161201145834.GA569@pox.localdomain>
 <20161201.111947.888676978252329124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:48290 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751997AbcLARUj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 12:20:39 -0500
In-Reply-To: <20161201.111947.888676978252329124.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.12.2016 17:19, David Miller wrote:
> Saying that ntuple filters can handle the early drop use case doesn't
> take into consideration the nature of the tables (hundreds of
> thousands of "evil" IP addresses), whether hardware can actually
> handle that (it can't), and whether simple IP address matching is the
> full extent of it (it isn't).

Yes, that is why you certainly use ntuple filters in combination with
some kind of high level business logic in user space.

I have to check but am pretty sure you can't even do the simplest thing
in XDP, parsing the apexes of DNS packets and checking them against a
hash table, because the program won't pass the verifier.
