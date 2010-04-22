From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v3] net: batch skb dequeueing from softnet input_pkt_queue
Date: Thu, 22 Apr 2010 09:35:44 +0800
Message-ID: <k2h412e6f7f1004211835q5c8e769did22080dd08b55439@mail.gmail.com>
References: <1271238738-8386-1-git-send-email-xiaosuo@gmail.com>
	<1271891149.7895.3751.camel@edumazet-laptop> <k2n65634d661004211623k3ce51c95o2c329529ce402eda@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	jamal <hadi@cyberus.ca>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:52484 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755474Ab0DVBgE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 21:36:04 -0400
Received: by iwn8 with SMTP id 8so1485702iwn.16
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 18:36:04 -0700 (PDT)
In-Reply-To: <k2n65634d661004211623k3ce51c95o2c329529ce402eda@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 22, 2010 at 7:23 AM, Tom Herbert <therbert@google.com> wrot=
e:
>
> How about just using two input_pkt_queue's (define
> input_pkt_queue[2])? =C2=A0One that is used to enqueue from RPS, and =
one
> that is being processed by process_backlog. =C2=A0Then the only thing=
 that
> needs to be done under lock in process_backlog is to switch the
> queues; =C2=A0something like sd->current_input_pkt_queue ^=3D 1
>

It is a better idea, IMO.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
