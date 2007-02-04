From: "Thomas Hisch" <t.hisch@gmail.com>
Subject: Re: [PATCH] ipv4: remove a call to skb_queue_len() in inet_diag.c
Date: Sun, 4 Feb 2007 21:41:35 +0100
Message-ID: <8ef77f2e0702041241y97d5906pb217c2fb984daab1@mail.gmail.com>
References: <Pine.LNX.4.64.0612311547200.30821@localhost.localdomain>
	 <20070204142921.GA5787@unknown-00-0d-60-79-ca-00.lan>
	 <20070204.122348.38681159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:5759 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551AbXBDUlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Feb 2007 15:41:39 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1149479uga
        for <netdev@vger.kernel.org>; Sun, 04 Feb 2007 12:41:37 -0800 (PST)
In-Reply-To: <20070204.122348.38681159.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/4/07, David Miller <davem@davemloft.net> wrote:
> From: Thomas Hisch <t.hisch@gmail.com>
> Date: Sun, 4 Feb 2007 15:29:21 +0100
>
> > remove unneeded call to skb_queue_len (skb_dequeue already checks queuelen) and
> > replace a sizeof() by a Netlink Macro
> >
> > Signed-off-by: Thomas Hisch <t.hisch@gmail.com>
>
> You don't understand the code you are editing :-)
>
> We want to process the number of packets present when we
> start the function, other threads can add more packets to
> the queue meanwhile and we don't want to keep dequeueing
> in that case or else we can theoretically run forever with
> a fast enough producer.
>
> Also, please post all networking patches to netdev@vger.kernel.org,
> the majority of the networking developers do not read linux-kernel.
>
> Thank you.
>
thanks for the advice. next time i should look more closely at the code ;)

i thought that this was a candidate for a cleanup as no other netlink
protocol used such a while loop condition.

Thomas.
