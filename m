From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ipv4: Restore accept_local behaviour in fib_validate_source()
Date: Thu, 14 Aug 2014 17:51:28 +0400
Message-ID: <53ECBEE0.7000802@cogentembedded.com>
References: <1408020352-22841-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Gregory Detal <gregory.detal@uclouvain.be>
To: =?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:45702 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754220AbaHNNvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 09:51:32 -0400
Received: by mail-la0-f44.google.com with SMTP id el20so1118595lab.3
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 06:51:31 -0700 (PDT)
In-Reply-To: <1408020352-22841-1-git-send-email-sebastien.barre@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/14/2014 04:45 PM, S=C3=A9bastien Barr=C3=A9 wrote:

> Commit 7a9bc9b introduced a short-circuit to avoid calling

    Please also specify that commit's summary line in parens.

> fib_validate_source when not needed. That change took rp_filter
> into account, but not accept_local. This resulted in a change
> of behaviour: with rp_filter and accept_local off, incoming
> packets with a local address in the source field should be
> dropped.

> Here is how to reproduce the change pre/post 7a9bc9b commit:
> -configure the same IPv4 address on hosts A and B.
> -try to send an arp request from B to A.
> -The arp request will be dropped before commit 7a9bc9b,

    s/arp/ARP/?

> but accepted and answered after that commit.

> This adds a check for ACCEPT_LOCAL, to maintain full
> fib validation in case it is 0.

> Signed-off-by: S=C3=A9bastien Barr=C3=A9 <sebastien.barre@uclouvain.b=
e>

WBR, Sergei
