From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v2 2/3] net: ipv6: Use ip6_datagram_send_common
 in L2TP IPv6.
Date: Wed, 23 Apr 2014 00:11:32 +0900
Message-ID: <CAKD1Yr1RAdVoBHKrW5ZBUnkLDkk9s_kpJUDZkOOBO_3FgVdD=w@mail.gmail.com>
References: <1398154415-24486-1-git-send-email-lorenzo@google.com>
 <1398159499-32413-1-git-send-email-lorenzo@google.com> <1398159499-32413-2-git-send-email-lorenzo@google.com>
 <1398176622.29946.46.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:35757 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbaDVPLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 11:11:53 -0400
Received: by mail-ie0-f175.google.com with SMTP id to1so5342196ieb.34
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 08:11:52 -0700 (PDT)
In-Reply-To: <1398176622.29946.46.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 22, 2014 at 11:23 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Please try CONFIG_IPV6=m and/or CONFIG_L2TP_IP=m then ;)

:-). I seem to remember having made this mistake before. :-)

> You forgot to EXPORT_SYMBOL(ip6_datagram_send_common)

Since this is a new function, and the only callers are kernel
functions that previously were not exported, I made this
EXPORT_SYMBOL_GPL.
