From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 1/1] neighbour: Support broadcast ARP in neighbor PROPE state
Date: Fri, 6 Feb 2015 22:46:04 -0800
Message-ID: <CAM_iQpVtU_i1U0TwaRJ+q-qGLMYYhJAU1GV4_t2Pq8TcwxAhxQ@mail.gmail.com>
References: <1423120837-28102-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	stefan.costandache@windriver.com, alexandre.dietsch@windriver.com,
	yue.tao@windriver.com, clinton.slabbert@windriver.com,
	eulfsam <ulf.samuelsson@ericsson.com>,
	"David S. Miller" <davem@davemloft.net>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:36663 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180AbbBGGqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2015 01:46:05 -0500
Received: by pdjp10 with SMTP id p10so9290882pdj.3
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 22:46:04 -0800 (PST)
In-Reply-To: <1423120837-28102-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 4, 2015 at 11:20 PM, zhuyj <zyjzyj2000@gmail.com> wrote:
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index bd29016..4d13edb 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -259,6 +259,23 @@ config IP_PIMSM_V2
>           gated-5). This routing protocol is not used widely, so say N unless
>           you want to play with it.
>
> +config ARP_PROBE_BCAST
> +       bool "IP: ARP send broadcast ARP, if probing using unicast fails"
> +       default y

Why make it default to y? Since we use the current behavior for a long time?
