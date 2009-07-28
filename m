From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] pppol2tp: calls unregister_pernet_gen_device() at
	unload time
Date: Tue, 28 Jul 2009 18:29:05 +0400
Message-ID: <20090728142905.GA4678@lenovo>
References: <20090723000100.d74d6b1c.akpm@linux-foundation.org> <43d009740907272340g7f98ed55lfff38bfedd867a99@mail.gmail.com> <4A6EBA88.8030205@cosmosbay.com> <4A6ECA3A.4050309@openvz.org> <4A6EEF69.1050001@cosmosbay.com> <4A6EF0BF.2050801@gmail.com> <4A6EF705.6070403@openvz.org> <4A6EFA35.3060309@gmail.com> <4A6EFB81.4090105@gmail.com> <4A6F017B.4060909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Pavel Emelyanov <xemul@openvz.org>,
	Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f216.google.com ([209.85.220.216]:38375 "EHLO
	mail-fx0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbZG1O3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 10:29:21 -0400
Received: by fxm12 with SMTP id 12so61972fxm.37
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 07:29:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A6F017B.4060909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Eric Dumazet - Tue, Jul 28, 2009 at 03:47:39PM +0200]
| Eric Dumazet a =E9crit :
| > Seems drivers/net/pppol2tp.c is a suspect...
| >=20
| > It uses register_pernet_gen_device() from pppol2tp_init()
| > but doesnt call unregister_pernet_gen_device()
|=20
| OK patch seems really easy...
|=20
| This bug was added in commit 4e9fb8016a351b5b9da7fea32bcfdbc9d836e421
| net: pppol2tp - introduce net-namespace functionality
|=20
| So this is a stable candidate I guess ?
|=20
| Thank you

Thanks a lot Eric!

Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>

	-- Cyrill
