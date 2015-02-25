From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] net: use skb->priority for overloading
 skb->dropcount and skb->reserved_tailroom instead of skb->mark
Date: Wed, 25 Feb 2015 08:50:28 -0800
Message-ID: <1424883028.5565.89.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424713924-6821-2-git-send-email-eyal.birger@gmail.com>
	 <1424713924-6821-4-git-send-email-eyal.birger@gmail.com>
	 <20150223205633.7fbd08d4@halley>
	 <20150223.164801.842537100812023841.davem@davemloft.net>
	 <CAHsH6GvfJHt6qA_9C1wsHEe1Y=ii9Z8a+3V_2D4NSiZZ4oBkvQ@mail.gmail.com>
	 <CAHsH6GtMGdkeKh9pdF64v4a4EX7Vsv1+gQP6nvrQqF=twg53Zg@mail.gmail.com>
	 <1424783915.5565.74.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHsH6GsqkA43Q-MMNOg+tVGSMjYMc9GUejOwV=VpkUQoaaGDBQ@mail.gmail.com>
	 <CAHsH6GthPu2w8F+jqbeMt9kano6uHdicrmMhsLugLt-0exLVUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Eyal Birger <eyal.birger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:61329 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbbBYQub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 11:50:31 -0500
Received: by mail-ig0-f176.google.com with SMTP id hl2so37062283igb.3
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 08:50:30 -0800 (PST)
In-Reply-To: <CAHsH6GthPu2w8F+jqbeMt9kano6uHdicrmMhsLugLt-0exLVUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-25 at 16:10 +0200, Eyal Birger wrote:

> Would you prefer this approach?

This looks fine to me.
