From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] neigh: set nud_state to NUD_INCOMPLETE when probing
 router reachability
Date: Tue, 13 May 2014 09:39:31 -0700
Message-ID: <1399999171.11539.116940145.6657B6F0@webmail.messagingengine.com>
References: <53703F52.9060900@cn.fujitsu.com>
 <20140512.143720.896863177762079657.davem@davemloft.net>
 <53717040.2070102@cn.fujitsu.com>
 <20140512.232511.1061979369646724590.davem@davemloft.net>
 <5371A9BD.2020106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jbenc@redhat.com
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from new2-smtp.messagingengine.com ([66.111.4.224]:41257 "EHLO
	new2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751029AbaEMQjc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2014 12:39:32 -0400
In-Reply-To: <5371A9BD.2020106@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 12, 2014, at 22:12, Duan Jiong wrote:
> In situation of connected router, the router which enter NUD_FAILED w=
ill
> never be choosed, and we only probe NUD_FAILED router's reachability =
by
> sending
> a single Neighbor Solicitation to that router's address.  Finally=EF=BC=
=8C we=20
> still send packets out through the connected router.

I agree with the patch mostly. The reason why I would liked to see
another change without changing nud_state is that we export those state=
s
to user space.

Greetings,

  Hannes
