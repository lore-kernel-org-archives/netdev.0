From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ixgbe: on recv increment rx.ring->stats.yields instead of
 tx
Date: Fri, 11 Dec 2015 16:47:33 +0300
Message-ID: <566AD3F5.9050502@cogentembedded.com>
References: <1449818646-29348-1-git-send-email-ptikhomirov@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Vagin <avagin@parallels.com>,
	Konstantin Khorenko <khorenko@parallels.com>, devel@openvz.org
To: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:34733 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741AbbLKNrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 08:47:37 -0500
Received: by lfcy184 with SMTP id y184so6078212lfc.1
        for <netdev@vger.kernel.org>; Fri, 11 Dec 2015 05:47:36 -0800 (PST)
In-Reply-To: <1449818646-29348-1-git-send-email-ptikhomirov@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/11/2015 10:24 AM, Pavel Tikhomirov wrote:

> It seem to be non intentionaly changed to tx in
> ms commit: adc810900a703ee78fe88fd65e086d359fec04b2
> ixgbe: Refactor busy poll socket code to address multiple issues

    scripts/checkpatch.pl now enforces uniform style of the commit citing, 
please follow.

> Lock is taken from ixgbe_low_latency_recv, and there under this
> lock we use ixgbe_clean_rx_irq so it looks wrong for me to increment
> tx counter.
>
> Yield stats can be shown through ethtool:
> ethtool -S enp129s0 | grep yield
>
> Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
[...]

MBR, Sergei
