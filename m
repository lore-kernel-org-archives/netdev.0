From: Ingo Molnar <mingo@elte.hu>
Subject: Re: ieee80211_crypt_wep.c:(.text+0x90dd7): undefined reference to
	`crypto_free_tfm'
Date: Mon, 10 Nov 2008 09:33:38 +0100
Message-ID: <20081110083338.GC22392@elte.hu>
References: <20081108075437.GA312@elte.hu> <31436f4a0811090110je363b8ya33477c26b6eed4b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Zhu Yi <yi.zhu@intel.com>,
	James Ketrenos <jketreno@linux.intel.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:47804 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753903AbYKJId4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2008 03:33:56 -0500
Content-Disposition: inline
In-Reply-To: <31436f4a0811090110je363b8ya33477c26b6eed4b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Shwatrz <dshwatrz@gmail.com> wrote:

> Hello,
>   Could it be that
> CONFIG_CRYPTO was set to 'm' manually ?
> I could not find a way to set CONFIG_CRYPTO to m
> in such a config file. Many configuration items sets it to be
> 'y' and when running "make menuconfig" the option to set it
> as a module does not exist.

the config was randconfig generated - and that setting survives a 
"make oldconfig" run as well, so it's a valid config file.

	Ingo
