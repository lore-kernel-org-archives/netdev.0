From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [RFC net-next 0/4] Support UID range routing.
Date: Mon, 28 Apr 2014 23:38:34 +0900
Message-ID: <CAKD1Yr0J3JXu9__LH6uKGsPYq+0jxiP1qhS2NTwT9gHitZ16_Q@mail.gmail.com>
References: <1398487705-13430-1-git-send-email-lorenzo@google.com> <535BB149.3090901@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, JP Abgrall <jpa@google.com>
To: David Newall <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:51003 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932076AbaD1Oiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 10:38:55 -0400
Received: by mail-ig0-f172.google.com with SMTP id hn18so4815359igb.17
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2014 07:38:54 -0700 (PDT)
In-Reply-To: <535BB149.3090901@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 26, 2014 at 10:14 PM, David Newall <davidn@davidnewall.com> wrote:
> I don't understand what your patch will do because, as I understand the
> word, "routing" means forwarding a packet one hop closer to the destination,
> so I expect you must reach the destination before you could know the UID.
> I'm probably missing something quite obvious. Could you illustrate a
> use-case?

This is useful for originated packets only, not forwarded packets.

It can be used if a host has more than one way to reach a destination
(multiple physical interfaces, multiple GRE tunnels, multiple real or
virtual routers on link, etc.) and wants to decide which to use based
on the user ID of the sending application.

The user ID could identify a service (e.g., mail vs. web), different
users/customers on the a shared server / machine, different users /
applications on a mobile device, etc.
