From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 00/18] mlx5 RoCE/RDMA packet sniffer
Date: Tue, 21 Jun 2016 16:10:26 +0300
Message-ID: <CALzJLG-_m_+-fKWjuuEbi4z-vO+jQmumqV+BoOxKPQ2wgkveaQ@mail.gmail.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:34177 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609AbcFUNKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 09:10:46 -0400
Received: by mail-yw0-f169.google.com with SMTP id i12so12872761ywa.1
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 06:10:46 -0700 (PDT)
In-Reply-To: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2016 at 5:43 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> Hi Dave,
>
> This patch set introduces mlx5 RoCE/RDMA packet sniffer, it allows
> mlx5e netdevice to receive RoCE/RDMA or RAW ETH traffic which isn't
> supposed to be passed to the kernel stack, for sniffing and diagnostics
> purposes.  This traffic is still not supposed to go through the whole
> network stack processing and should only go to the non-protocol specific
> handlers (ptype_all). e.g: tcpdump, etc ..

Dave,

I would like to drop this series, we did some evaluation and there is
no straightforward way to tell the kernel to not process traffic that
should only go to tcpdump or (ptype_all).

We are evaluating a semi-pure userspace solution to sniff user space
traffic directly form userspace into libpcap. (verbs/rdma
plugin/extension for libpcap)

Sorry for any inconvenience,

Thanks,
Saeed.
