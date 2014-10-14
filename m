From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP socket receives strange packet
Date: Tue, 14 Oct 2014 08:00:52 -0700
Message-ID: <1413298852.17109.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <543D2EB2.4000009@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
To: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:50580 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932276AbaJNPAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 11:00:54 -0400
Received: by mail-pa0-f41.google.com with SMTP id eu11so8075554pac.0
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 08:00:53 -0700 (PDT)
In-Reply-To: <543D2EB2.4000009@oktetlabs.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-10-14 at 18:09 +0400, Yurij M. Plotnikov wrote:
> Connected TCP socket receives packet without timestamps option which 
> exists in SYN, SYNACK and ACK. It is packet 4 in attached tcpdump output.
> 
> tcpdump output description: The host has address 10.208.10.1 (server) 
> and the peer host has address 10.208.10.2 (client).
> 
> Establishing connection: Timestamps option exists in SYN, SYNACK and ACK 
> (packets 1, 2 and 3 in attached file), so accepted socket should receive 
> packets only with timestamps option.

Can you point the RFC paragraph stating so ?

I have wondering if this behavior was correct some time ago, and could
not find a definitive answer.

RFC 1323 4.2.1 seems to suggest it is valid to accept a segment without
TS.

R1) If there is a Timestamps option in the arriving segment...


 There is no : Else drop the segment.
