From: pravin shelar <pshelar@ovn.org>
Subject: Re: [net-next,v3] openvswitch: Add packet truncation support.
Date: Fri, 10 Jun 2016 13:22:15 -0700
Message-ID: <CAOrHB_A-gnvndiT4ejx9k9ByXPLbz5_sAj2ZqaqfvRSrFMF24w@mail.gmail.com>
References: <1465584573-58583-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:54786 "EHLO
	relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbcFJUWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 16:22:20 -0400
Received: from mfilter39-d.gandi.net (mfilter39-d.gandi.net [217.70.178.170])
	by relay2-d.mail.gandi.net (Postfix) with ESMTP id 91A13C5A53
	for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 22:22:18 +0200 (CEST)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
	by mfilter39-d.gandi.net (mfilter39-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id khvFNa0oKfD8 for <netdev@vger.kernel.org>;
	Fri, 10 Jun 2016 22:22:17 +0200 (CEST)
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	(Authenticated sender: pshelar@ovn.org)
	by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 11FD0C5A4E
	for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 22:22:16 +0200 (CEST)
Received: by mail-io0-f177.google.com with SMTP id n127so75242976iof.3
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 13:22:16 -0700 (PDT)
In-Reply-To: <1465584573-58583-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 10, 2016 at 11:49 AM, William Tu <u9012063@gmail.com> wrote:
> The patch adds a new OVS action, OVS_ACTION_ATTR_TRUNC, in order to
> truncate packets. A 'max_len' is added for setting up the maximum
> packet size, and a 'cutlen' field is to record the number of bytes
> to trim the packet when the packet is outputting to a port, or when
> the packet is sent to userspace.
>
> Signed-off-by: William Tu <u9012063@gmail.com>
> Cc: Pravin Shelar <pshelar@nicira.com>
>
> ---
> v2 -> v3
> - Change minimum packet size after truncate to 14 (ETH_HLEN).
> - Pass cutlen to userspace action.
> - Allocate smaller skb buffer if packet is truncated.
>
> v1 -> v2:
> - Use 32 bits cutlen and fix unnecessary cutlen initilization.
> - Fix cutlen leaks to remaining actions under sample action.
> - In queue_userspace_packet, don't extract hlen when using skb_zerocopy.
> ---

Acked-by: Pravin B Shelar <pshelar@ovn.org>

Thanks.
