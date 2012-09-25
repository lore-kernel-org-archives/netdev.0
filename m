From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: Re: bridge igmp snooping implementation
Date: Tue, 25 Sep 2012 23:12:00 +0800
Message-ID: <CAF1ivSZqjaWvj4JkkzM_PTBuqYSKDdkYXxijfRWdcWqaF_P4-g@mail.gmail.com>
References: <506184ED.5040104@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:53644 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750919Ab2IYPMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 11:12:52 -0400
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	(Authenticated sender: mlin@ss.pku.edu.cn)
	by mail.ss.pku.edu.cn (Postfix) with ESMTPA id 0A867DBCAE
	for <netdev@vger.kernel.org>; Tue, 25 Sep 2012 23:12:04 +0800 (CST)
Received: by lbon3 with SMTP id n3so274141lbo.19
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2012 08:12:00 -0700 (PDT)
In-Reply-To: <506184ED.5040104@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 25, 2012 at 6:18 PM, Felix Fietkau <nbd@openwrt.org> wrote:
> Hi,
>
> I'v been looking at the bridge IGMP snooping code and I noticed that it
> appears to not keep track of multicast group member IP addresses. Is
> this intentional?
>
> It seems to me that this would lead to issues when multiple members of
> the same multicast group are behind the same bridge port, and one of
> them leaves.
>
> I'm currently looking into adding a feature that allows bridge ports to
> be configured to selectively turn multicast traffic into unicast
> traffic. For this I would need to change the code to keep track of
> member IP and MAC addresses.

Good idea. This can help to resolve my problem at:
http://marc.info/?l=linux-netdev&m=134855468803809&w=2

Thanks.

>
> This helps a lot on 802.11, where unicast is often much cheaper than
> multicast, even when sending out duplicate packets (higher data rates
> and aggregation heavily reduce airtime utilization).
>
> - Felix
