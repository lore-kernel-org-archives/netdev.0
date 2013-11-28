From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: introduce SO_BPF_EXTENSIONS
Date: Thu, 28 Nov 2013 09:31:29 -0800
Message-ID: <1385659889.5352.25.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1385639832-3938-1-git-send-email-msekleta@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: Michal Sekletar <msekleta@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:56864 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759118Ab3K1Rba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 12:31:30 -0500
Received: by mail-pd0-f175.google.com with SMTP id w10so12290296pde.20
        for <netdev@vger.kernel.org>; Thu, 28 Nov 2013 09:31:30 -0800 (PST)
In-Reply-To: <1385639832-3938-1-git-send-email-msekleta@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-28 at 12:57 +0100, Michal Sekletar wrote:

> +enum {
> +	BPF_ANC_FLAG_PROTOCOL         = (1 << 0),
> +	BPF_ANC_FLAG_PKTTYPE          =	(1 << 1),
> +	BPF_ANC_FLAG_IFINDEX          = (1 << 2),
> +	BPF_ANC_FLAG_NLATTR           = (1 << 3),
> +	BPF_ANC_FLAG_NLATTR_NEST      = (1 << 4),
> +	BPF_ANC_FLAG_MARK             = (1 << 5),
> +	BPF_ANC_FLAG_QUEUE            = (1 << 6),
> +	BPF_ANC_FLAG_HATYPE           = (1 << 7),
> +	BPF_ANC_FLAG_RXHASH           = (1 << 8),
> +	BPF_ANC_FLAG_CPU              = (1 << 9),
> +	BPF_ANC_FLAG_ALU_XOR_X        = (1 << 10),
> +	BPF_ANC_FLAG_SECCOMP_LD_W     = (1 << 11),
> +	BPF_ANC_FLAG_VLAN_TAG         = (1 << 12),
> +	BPF_ANC_FLAG_VLAN_TAG_PRESENT = (1 << 13),
> +	BPF_ANC_FLAG_PAY_OFFSET       = (1 << 14),
> +};
> +

Why spending 15 bits (out of 32), for all these extensions ?

It seems a single one should be enough.

I do not think we will ever remove one of these extension.
