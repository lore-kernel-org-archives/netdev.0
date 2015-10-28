From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3 0/4] net: clean up interactions of CHECKSUM_PARTIAL and fragmentation
Date: Wed, 28 Oct 2015 10:33:28 +0100
Message-ID: <87wpu7bamv.fsf@stressinduktion.org>
References: <1445982042-3207-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: edumazet@google.com, vyasevich@gmail.com, bcodding@redhat.com,
	tom@herbertland.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:57679 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751159AbbJ1Jda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 05:33:30 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 0BAB52030B
	for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 05:33:30 -0400 (EDT)
In-Reply-To: <1445982042-3207-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:

> This series fixes wrong checksums on the wire for IPv4 and IPv6. Large
> send buffers and especially NFS lead to wrong checksums in both IPv4
> and IPv6.
>
> CHECKSUM_PARTIAL skbs should not receive the respective fragmentations
> functions, so we add WARN_ON_ONCE to those functions to fix up those as
> soon as they get reported.
>
> Thanks!
>
> Changelog:
> v2: added v4 checks
> v3: removed WARN_ON_ONCES (advice by Tom Herbert)
>
> Hannes Frederic Sowa (4):
>   ipv4: no CHECKSUM_PARTIAL on MSG_MORE corked sockets
>   ipv4: add defensive check for CHECKSUM_PARTIAL skbs in ip_fragment
>   ipv6: no CHECKSUM_PARTIAL on MSG_MORE corked sockets

Those patches are actually for net and not for net-next, sorry. Guess
I messed it up with Ctrl-R foo.

Thanks,
Hannes
