From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: request for stable inclusion
Date: Mon, 18 Apr 2016 09:57:25 +0300
Message-ID: <CAJ3xEMjyA=aAQ-na3d1y3g8r4_=ZHoAFh+Xq+DDJO3TKo=ktSA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Huy Nguyen <huyn@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:35239 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbcDRG50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 02:57:26 -0400
Received: by mail-ig0-f181.google.com with SMTP id gy3so65276879igb.0
        for <netdev@vger.kernel.org>; Sun, 17 Apr 2016 23:57:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Could you please push to -stable the UAR patch (below), it allows mlx4
to run on PPC systems without hacking PCI BAR sizes. The patch
introduced small regression for people that do prefer to run non
modified VF drivers with modified host driver, and hence should be
accompanied by the  backward compatibility (below too)

76e39cc net/mlx4_core: Fix backward compatibility on VFs
85743f1 net/mlx4_core: Set UAR page size to 4KB regardless of system page size

Thanks,

Or.
