From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [RFC PATCH] packet: Add fanout support.
Date: Wed, 22 Jun 2011 09:44:00 +0800
Message-ID: <BANLkTinxvHbkCLehJkqoCfryeTqL0zhWiw@mail.gmail.com>
References: <20110621.034627.30677905865798284.davem@davemloft.net>
 <BANLkTikgTqGY=S9UVik6wjSp5WE4WLmKtA@mail.gmail.com> <4E009C5A.8060208@inliniac.net>
 <20110621.143902.274396574751811372.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: victor@inliniac.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:58664 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757693Ab1FVBoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 21:44:21 -0400
Received: by bwz15 with SMTP id 15so362394bwz.19
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2011 18:44:20 -0700 (PDT)
In-Reply-To: <20110621.143902.274396574751811372.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2011 at 5:39 AM, David Miller <davem@davemloft.net> wrote:
> From: Victor Julien <victor@inliniac.net>
> Date: Tue, 21 Jun 2011 15:27:54 +0200
>
>> From a Suricata IDS point of view, I would need to have the
>> fragments of a flow/tuple on the same socket.
>
> Currently you would, they would all go to the first socket in
> the fanout.
>

I think he also needs all the packets belong to the related
connections are received via the same socket. I am afraid that he has
to dispatch these kind of packets among the uesrland processes again.
:)

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
