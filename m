From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [RFC net-next 0/4] Support UID range routing.
Date: Sat, 3 May 2014 04:15:38 +0900
Message-ID: <CAKD1Yr0wqj0wG3Ges9NeqMBALO-SxY9KTgZo_sp_8VYKnihKMQ@mail.gmail.com>
References: <1398487705-13430-1-git-send-email-lorenzo@google.com>
 <535BB149.3090901@davidnewall.com> <CAKD1Yr0J3JXu9__LH6uKGsPYq+0jxiP1qhS2NTwT9gHitZ16_Q@mail.gmail.com>
 <20140428.125807.409036177577836732.davem@davemloft.net> <CAKD1Yr1HN4=42JYfe9LYguWukXxNE38vvwLBt-aEeQ-zSisN9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Newall <davidn@davidnewall.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	JP Abgrall <jpa@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:33991 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136AbaEBTP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 15:15:59 -0400
Received: by mail-ie0-f179.google.com with SMTP id lx4so5540642iec.10
        for <netdev@vger.kernel.org>; Fri, 02 May 2014 12:15:58 -0700 (PDT)
In-Reply-To: <CAKD1Yr1HN4=42JYfe9LYguWukXxNE38vvwLBt-aEeQ-zSisN9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 4:01 AM, Lorenzo Colitti <lorenzo@google.com> wrote:
> Basically, what this patch calls "UID" is what the xt_owner module and
> xt_LOG iptables modules consider to be the "owner" of a socket, what
> nfqueue presents as the user ID, what shows up in
> /proc/net/{udp,tcp,raw} in the "uid" column, etc. In most cases this
> is the effective UID that made the call to socket() or accept().
>
> This patch allows using that concept in routing. This can be done
> today with "iptables -m owner --uid-owner 12345 -j MARK --set-mark
> 0xbeef; ip rule from fwmark 0xbeef lookup 100", but that has the
> limitations I set out in my original message (e.g., incorrect source
> address).

David,

did that help clarify what I'm proposing here? Does this patch still
seem misguided to you even though its semantics match existing
functionality?

Lorenzo
