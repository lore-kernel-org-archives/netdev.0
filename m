From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [RFC net-next 0/4] Support UID range routing.
Date: Wed, 30 Apr 2014 13:36:02 +0900
Message-ID: <CAKD1Yr2J-UgU+Ycu4pf3L51-1tN1fnxQxDo8fLj+9yb4jQuGZg@mail.gmail.com>
References: <1398487705-13430-1-git-send-email-lorenzo@google.com>
 <535BB149.3090901@davidnewall.com> <CAKD1Yr0J3JXu9__LH6uKGsPYq+0jxiP1qhS2NTwT9gHitZ16_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, JP Abgrall <jpa@google.com>
To: David Newall <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:47891 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbaD3EgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 00:36:23 -0400
Received: by mail-ie0-f169.google.com with SMTP id rl12so1370422iec.28
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 21:36:22 -0700 (PDT)
In-Reply-To: <CAKD1Yr0J3JXu9__LH6uKGsPYq+0jxiP1qhS2NTwT9gHitZ16_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2014 at 11:38 PM, Lorenzo Colitti <lorenzo@google.com> wrote:
> The user ID could identify a service (e.g., mail vs. web), different
> users/customers on the a shared server / machine, different users /
> applications on a mobile device, etc.

Example real-world use case: the Android VPN framework currently uses
iptables owner matching to mark packets, fwmark routing, and
masquerade to send traffic on the correct VPN for the user (Android
tablets are multi-user devices).

The use of NAT forces the system to use MSS rewriting instead of PMTUD
and makes it impossible for the app to know its real IP address and
port, breaking apps like SIP clients (in addition to requiring
conntrack to keep state locally-originated connections). Per-UID
routing would solve all these problems in a much cleaner way.
