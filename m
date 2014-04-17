From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] filter: added BPF random opcode
Date: Wed, 16 Apr 2014 18:38:16 -0700
Message-ID: <1397698696.4222.138.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1397585816-1267-1-git-send-email-chema@google.com>
	 <CAMEtUuw3-LEuwJ2cAQ+F-tu_-wzy4HK4ZteAuJpYfY9hW66+FA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chema Gonzalez <chema@google.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:64023 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753437AbaDQBiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 21:38:18 -0400
Received: by mail-pb0-f44.google.com with SMTP id rp16so11610283pbb.3
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2014 18:38:17 -0700 (PDT)
In-Reply-To: <CAMEtUuw3-LEuwJ2cAQ+F-tu_-wzy4HK4ZteAuJpYfY9hW66+FA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-04-15 at 23:24 -0700, Alexei Starovoitov wrote:

> In particular I don't find the reason of moving random
> packet sampling into kernel to be that great.
> pcap cannot receive them quickly enough anyway,
> so there are drops already.
> Just randomly pick packets that reached the user space.
> Why add this to the kernel? I don't see how it can improve accuracy.

It has nothing to do with speed or accuracy.

Being able to intercept 0.001 % of the packets (and not 0.001 % of the
flows...) can be useful to network operators.

_Then_ if its super super super fast, thats better, of course.

Suggesting to intercept all packets, then filtering 99.999 % of them in
user space is not going to work. Its going to be super super super slow.
