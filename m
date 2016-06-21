From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 12/18] IB/mlx5: Add kernel offload flow-tag
Date: Tue, 21 Jun 2016 08:18:49 -0700
Message-ID: <CANn89iJbaOR5HpoaQLHoBGhariTACf-OLKRWqP3KBacvOUgGdg@mail.gmail.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
 <1466174639-14576-13-git-send-email-saeedm@mellanox.com> <20160617160007.GA52082@ast-mbp.thefacebook.com>
 <CALzJLG-uoMKjZCC312JjfqnQaUW_-31eqeg0bQd+r3qp4Fa1ag@mail.gmail.com>
 <20160621021836.GA81638@ast-mbp.thefacebook.com> <CALzJLG8+xhJDO9FaGF+9OiBq1s1LD_cb3y-ybUkFD7DJG=SRaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f177.google.com ([209.85.161.177]:34632 "EHLO
	mail-yw0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751672AbcFUPTU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 11:19:20 -0400
Received: by mail-yw0-f177.google.com with SMTP id i12so16400829ywa.1
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 08:18:51 -0700 (PDT)
In-Reply-To: <CALzJLG8+xhJDO9FaGF+9OiBq1s1LD_cb3y-ybUkFD7DJG=SRaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2016 at 6:04 AM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:

>
> Alexei , I don't understand your concern.
> We already have a full/complete working dpdk bypass solution in
> userspace nothing extra is required from the kernel.
>
> We just want to see this traffic and any other rdma traffic in tcpdump
> or other standard sniffing tools.
>
> Anyway we brainstormed this internally today and we don't like the
> "skb->protocol = 0xffff" solution,

One solution would be to setup a special netdev used only for sniffers
(No IP address on it)

-> Only changes would happen in the driver, to set skb->dev to this
'debug' device.
