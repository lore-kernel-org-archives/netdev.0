From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net v2] openvswitch: update checksum in {push,pop}_mpls
Date: Tue, 31 May 2016 12:28:48 -0700
Message-ID: <CAOrHB_Ce91ue5HP+eqJGkLPNKRe10JXKXxs7=nshi36b7iCNdw@mail.gmail.com>
References: <1464584665-8512-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin Shelar <pshelar@nicira.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:56283 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbcEaT2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 15:28:53 -0400
Received: from mfilter41-d.gandi.net (mfilter41-d.gandi.net [217.70.178.173])
	by relay4-d.mail.gandi.net (Postfix) with ESMTP id 46AA61720AC
	for <netdev@vger.kernel.org>; Tue, 31 May 2016 21:28:51 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
	by mfilter41-d.gandi.net (mfilter41-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id EXlzfx-TF9pI for <netdev@vger.kernel.org>;
	Tue, 31 May 2016 21:28:50 +0200 (CEST)
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	(Authenticated sender: pshelar@ovn.org)
	by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id EB90A172097
	for <netdev@vger.kernel.org>; Tue, 31 May 2016 21:28:49 +0200 (CEST)
Received: by mail-io0-f171.google.com with SMTP id t40so935753ioi.0
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 12:28:49 -0700 (PDT)
In-Reply-To: <1464584665-8512-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 29, 2016 at 10:04 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> In the case of CHECKSUM_COMPLETE the skb checksum should be updated in
> {push,pop}_mpls() as they the type in the ethernet header.
>
> As suggested by Pravin Shelar.
>
> Cc: Pravin Shelar <pshelar@nicira.com>
> Fixes: 25cd9ba0abc0 ("openvswitch: Add basic MPLS support to kernel")
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Looks good to me.

Acked-by: Pravin B Shelar <pshelar@ovn.org>
