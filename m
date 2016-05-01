From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH v2 1/9] net: Disable segmentation if checksumming
 is not supported
Date: Sun, 1 May 2016 23:30:38 +0300
Message-ID: <CAJ3xEMhCHny00V0GAFH1a9NXj52q5M4B1Rmz+JMCT8YsK02vKQ@mail.gmail.com>
References: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
	<20160429224308.12418.51424.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "talal@mellanox.com" <talal@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	michael.chan@broadcom.com, David Miller <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34002 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356AbcEAUaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 16:30:39 -0400
Received: by mail-io0-f171.google.com with SMTP id 190so147043008iow.1
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 13:30:38 -0700 (PDT)
In-Reply-To: <20160429224308.12418.51424.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 30, 2016 at 1:43 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
> In the case of the mlx4 and mlx5 driver they do not support IPv6 checksum
> offload for tunnels.

Alex,

To clarify, when you say "not support IPv6 checksum for tunnels", you
refer to the offloading of the outer or inner checksum?

Still (me and I think also Tariq from our driver team) catching up on
the series, the primitives and conventions you are introducing using
and how this applies on mlx5. I saw that Saeed acked the the mlx5e
patches (7 and 8).

Specifically, the mlx4 patches are practically fixes so if they don't
land in 4.7 via net-next we can get them there through net, lets give
us the few more days needed to catch up from our side.

Or.
