From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 13/18] net: Add offload kernel net stack packet type
Date: Fri, 17 Jun 2016 08:12:04 -0700
Message-ID: <CANn89i+6gf_KcC1rwDYZLUVVCUzqyz+wDOGzCMpM5_pRRs0-HQ@mail.gmail.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com> <1466174639-14576-14-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Patrick McHardy <kaber@trash.net>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:36401 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933580AbcFQPMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 11:12:16 -0400
Received: by mail-yw0-f177.google.com with SMTP id v78so10150631ywa.3
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 08:12:15 -0700 (PDT)
In-Reply-To: <1466174639-14576-14-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2016 at 7:43 AM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> From: Maor Gottlieb <maorg@mellanox.com>
>
> Add new packet type to skip kernel specific protocol handlers.
>
> This is needed so device drivers can pass packets up to user space
> (af_packet/tcpdump, etc..) without the need for them to go through
> the whole kernel data path.
>
> Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Patrick McHardy <kaber@trash.net>
> CC: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>

This breaks BPF quite badly.

git grep SKF_AD_PKTTYPE
