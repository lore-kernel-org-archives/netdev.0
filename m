From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 0/4] net/mlx4_en: fix stats
Date: Thu, 26 May 2016 05:57:11 -0700
Message-ID: <1464267431.5939.81.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
	 <271107bf-61b4-78ec-3c9a-4d57e88fad90@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36149 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753354AbcEZM5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 08:57:13 -0400
Received: by mail-pf0-f195.google.com with SMTP id g132so2279127pfb.3
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 05:57:12 -0700 (PDT)
In-Reply-To: <271107bf-61b4-78ec-3c9a-4d57e88fad90@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-26 at 12:44 +0300, Tariq Toukan wrote:
> Hi Eric,
> 
> > mlx4 has various bugs in its ndo_get_stats() and related functions.
> > This patch series address the obvious issues.
> > Remaining ones will be discussed later.
> >
> Thanks for the fixes.
> I see they were already applied.
> I reviewed them all and replied to patch 4/4, the rest look good to me.
> Please CC me as the maintainer of mlx4_en on future patches.

If you are mlx4_en maintainer, please submit an official patch so that
non Mellanox employees can get this information using the normal way ?

Thanks.

diff --git a/MAINTAINERS b/MAINTAINERS
index 8d397157981c..4a35221e4819 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7250,6 +7250,7 @@ F:	drivers/scsi/megaraid/
 
 MELLANOX ETHERNET DRIVER (mlx4_en)
 M: 	Eugenia Emantayev <eugenia@mellanox.com>
+M:	Tariq Toukan <tariqt@mellanox.com>
 L:	netdev@vger.kernel.org
 S:	Supported
 W:	http://www.mellanox.com
