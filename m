From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next 0/4] net/mlx4_en: Add accelerated RFS support
Date: Thu, 19 Jul 2012 00:22:42 +0300
Message-ID: <CAJZOPZL8842H9H7404qjugCPpdhijjUhxk0Kn6BfBONCbE-tNA@mail.gmail.com>
References: <1342621162-18498-1-git-send-email-ogerlitz@mellanox.com>
	<20120718.114158.2161516212050365274.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: roland@kernel.org, netdev@vger.kernel.org, oren@mellanox.com,
	yevgenyp@mellanox.com, amirv@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:52527 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978Ab2GRVWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 17:22:43 -0400
Received: by gglu4 with SMTP id u4so2102739ggl.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 14:22:43 -0700 (PDT)
In-Reply-To: <20120718.114158.2161516212050365274.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 18, 2012 at 9:41 PM, David Miller <davem@davemloft.net> wrote:

> Please use CONFIG_RFS_ACCEL consistently to protect this feature
> in your driver sources.
>
> Using CPU_RMAP in a few places is inconsistent, and not what other
> drivers do.

We're indeed using CONFIG_RFS_ACCEL across the place, and only in two
places which deal directly with rmap use CPU_RMAP. The latter is
selected by RFS_ACCEL, but if you feel this is inconsistent, will
change to use only one define.

Or.
