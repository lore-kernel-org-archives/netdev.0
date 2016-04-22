From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: mlx5e throwing RTNL_ASSERT error on vxlan_get_rx_port
Date: Fri, 22 Apr 2016 12:30:12 -0700
Message-ID: <CAKgT0Ud2yc3ZgMpSwdWAvaJ6b2-Q5QO=SEOb709y1BHepU_rQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Saeed Mahameed <saeedm@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:37780 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074AbcDVTaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 15:30:13 -0400
Received: by mail-ig0-f172.google.com with SMTP id g8so25481213igr.0
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 12:30:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From what I can tell it looks like the recent commit that changed the
behavior for vxlan_get_rx_port has broken the mlx5 driver as it was
calling vxlan_get_rx_port in mlx5e_create_netdev which didn't hold the
rtnl lock.  As a result it is throwing RTNL_ASSERT errors.

I'm not sure if anyone has already seen this or not but I thought I
would bring it to your attention.  Odds are this probably something
that needs to be fixed in the mlx5e driver and if I have time I might
get to it sometime in the next several days if nobody else ends up
addressing it.

Thanks.

- Alex
