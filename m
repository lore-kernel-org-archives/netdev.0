From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v3 1/3] net: ipv6: Unduplicate
 {raw,udp}v6_sendmsg code
Date: Wed, 23 Apr 2014 15:38:31 +0900
Message-ID: <CAKD1Yr0GiHzrrrF7JwxMCKsyMA_h-aT=0jKNZ-t9BKh-+w1fVg@mail.gmail.com>
References: <1398154415-24486-1-git-send-email-lorenzo@google.com>
 <1398179656-9313-1-git-send-email-lorenzo@google.com> <1398182345.29946.51.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:42966 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140AbaDWGiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 02:38:52 -0400
Received: by mail-ig0-f182.google.com with SMTP id uy17so633595igb.9
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 23:38:51 -0700 (PDT)
In-Reply-To: <1398182345.29946.51.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2014 at 12:59 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Don't you leak a reference on struct ip6_flowlabel *flowlabel ?

Yes. Should be fixed in patch series 4.
