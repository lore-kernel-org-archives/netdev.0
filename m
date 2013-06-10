From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use zerocopy if applicable when
 performing the upcall
Date: Mon, 10 Jun 2013 13:55:03 -0700
Message-ID: <CAEP_g=8fOk-g6ZLpzefgg=_+MHxonp1AAs+H+jmZhFAcNMjMYQ@mail.gmail.com>
References: <CAEP_g=944Wq982rDSC0hrqUBu8Sf6MCtQN0NhgyU5FDr9UB3ww@mail.gmail.com>
 <20130607122139.GA21856@casper.infradead.org> <CAEP_g=87=0bAP_QQVVXRXzqMA-9Xj5dXvsjpfe4MQ_k2x5n9cA@mail.gmail.com>
 <20130610.134331.1301662479712409021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog135.obsmtp.com ([74.125.149.84]:48851 "HELO
	na3sys009aog135.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750812Ab3FJUzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 16:55:24 -0400
Received: by mail-ie0-f170.google.com with SMTP id e11so1894057iej.1
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 13:55:23 -0700 (PDT)
In-Reply-To: <20130610.134331.1301662479712409021.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 10, 2013 at 1:43 PM, David Miller <davem@davemloft.net> wrote:
> From: Jesse Gross <jesse@nicira.com>
> Date: Mon, 10 Jun 2013 13:34:23 -0700
>
>> Well, this is the slow path. I don't want to force userspace to deal
>> with this because it's an internal kernel optimization that is
>> platform-specific and requires carrying additional metadata around.
>
> I think the grounds for this rejection is over the top and
> unreasonable.

I didn't reject it and in fact, I expect it to go in. I asked for
numbers as to how this affects the common case.
