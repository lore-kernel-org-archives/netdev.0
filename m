From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [RFC net-next 0/4] Support UID range routing.
Date: Wed, 30 Apr 2014 17:04:14 +0900
Message-ID: <CAKD1Yr23gyvm6nTRp96puuHVmKfhfvga07yz=nguueWtKD9a5A@mail.gmail.com>
References: <1398487705-13430-1-git-send-email-lorenzo@google.com>
 <535BB149.3090901@davidnewall.com> <CAKD1Yr0J3JXu9__LH6uKGsPYq+0jxiP1qhS2NTwT9gHitZ16_Q@mail.gmail.com>
 <CAKD1Yr2J-UgU+Ycu4pf3L51-1tN1fnxQxDo8fLj+9yb4jQuGZg@mail.gmail.com> <5360ABD3.2020506@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, JP Abgrall <jpa@google.com>
To: David Newall <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:62809 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbaD3IEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 04:04:39 -0400
Received: by mail-ie0-f170.google.com with SMTP id rd18so1538937iec.29
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 01:04:38 -0700 (PDT)
In-Reply-To: <5360ABD3.2020506@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 30, 2014 at 4:52 PM, David Newall <davidn@davidnewall.com> wrote:
> The original address *is* the real address.  NAT breaks IP's design and is a very mixed blessing.  NAT isn't needed nor used with IPv6, and being in IPv4's twilight years, an argument predicated on NAT is not very convincing.

Right. NAT is what the code does today. This change allows getting rid of it.

> I feel that describing the patch as routing is misleading, as it performs only outbound link selection.  It fosters an expectation of bi-directionality, and that is not the case.  It will often result in asymmetric routes.

The patch adds the capability to take into account the user ID when
doing a routing lookup. The routing lookup affects outbound interface,
but it also affects source address selection, MTU and advertised TCP
MSS, and a variety of other parameters that are configurable on a
per-route basis (e.g., congestion window).
