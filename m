From: Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>
Subject: Re: [PATCH] pppoe: fix race at init time
Date: Wed, 29 Jul 2009 11:55:45 +0800
Message-ID: <43d009740907282055t44bfa2e2md3afa514d4b2d7e6@mail.gmail.com>
References: <43d009740907272340g7f98ed55lfff38bfedd867a99@mail.gmail.com>
	<4A6ECA3A.4050309@openvz.org> <4A6EEF69.1050001@cosmosbay.com>
	<4A6EF0BF.2050801@gmail.com> <4A6EF705.6070403@openvz.org>
	<4A6EFA35.3060309@gmail.com> <4A6EFB81.4090105@gmail.com>
	<4A6F017B.4060909@gmail.com> <4A6F397D.6010606@gmail.com>
	<20090728184834.GD4678@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Pavel Emelyanov <xemul@openvz.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f213.google.com ([209.85.217.213]:54899 "EHLO
	mail-gx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbZG2D4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 23:56:06 -0400
Received: by gxk9 with SMTP id 9so952460gxk.13
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 20:56:05 -0700 (PDT)
In-Reply-To: <20090728184834.GD4678@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/7/29 Cyrill Gorcunov <gorcunov@gmail.com>:
> [Eric Dumazet - Tue, Jul 28, 2009 at 07:46:37PM +0200]
> ...
> | So Igor still has a panic... lets try a third patch then :)
[...]
> Hmm. It seems the problem is not in pppoe_init_net since it's
> called *before* dev_add_pack via register_pernet_gen_device
> (which is protected by a global net mutex). Or I miss something?
>
> (sorry guys I have quite a limited internet connection this week)

	At last the 3rd patch was also unable to fix the bug.

-- 
End of message. Next message?
