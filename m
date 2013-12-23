From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next V2 2/2] net/mlx4_en: Add netdev support for
 TCP/IP offloads of vxlan tunneling
Date: Mon, 23 Dec 2013 12:54:18 +0200
Message-ID: <CAJZOPZJaew4Wr9yjZ6PYhXcL7Th9BZY+xQVpKKpx8eErkO06pA@mail.gmail.com>
References: <1387725972-10244-1-git-send-email-ogerlitz@mellanox.com>
	<1387725972-10244-3-git-send-email-ogerlitz@mellanox.com>
	<20131222.181202.168681767663560253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Yan Burman <yanb@mellanox.com>,
	Alexei Starovoitov <ast@plumgrid.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:46027 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753213Ab3LWKyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 05:54:19 -0500
Received: by mail-pd0-f171.google.com with SMTP id z10so4994902pdj.16
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 02:54:18 -0800 (PST)
In-Reply-To: <20131222.181202.168681767663560253.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 23, 2013 at 1:12 AM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Sun, 22 Dec 2013 17:26:12 +0200
>
>> +     if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
>> +     if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
>> +     if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
>> +         (mdev->dev->caps.tunnel_offload_mode ==  MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
>> +     if ((mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN)) {
>
> Way too many parenthesis, this isn't LISP :-)

mmm, not sure how this happened... anyway, will fix and submit V3
