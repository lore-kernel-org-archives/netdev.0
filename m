From: "David Shwatrz" <dshwatrz@gmail.com>
Subject: Re: ieee80211_crypt_wep.c:(.text+0x90dd7): undefined reference to `crypto_free_tfm'
Date: Sun, 9 Nov 2008 11:10:40 +0200
Message-ID: <31436f4a0811090110je363b8ya33477c26b6eed4b@mail.gmail.com>
References: <20081108075437.GA312@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>, "Zhu Yi" <yi.zhu@intel.com>,
	"James Ketrenos" <jketreno@linux.intel.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:15982 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754014AbYKIJKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2008 04:10:41 -0500
Received: by rv-out-0506.google.com with SMTP id k40so1991349rvb.1
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2008 01:10:40 -0800 (PST)
In-Reply-To: <20081108075437.GA312@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
  Could it be that
CONFIG_CRYPTO was set to 'm' manually ?
I could not find a way to set CONFIG_CRYPTO to m
in such a config file. Many configuration items sets it to be
'y' and when running "make menuconfig" the option to set it
as a module does not exist.
rgs,
DS


On Sat, Nov 8, 2008 at 9:54 AM, Ingo Molnar <mingo@elte.hu> wrote:
>
> not sure whether this has been reported before, but with latest upstream
> i get this new build failure with certain (rare, randconfig) configs:
>
>  net/built-in.o: In function `prism2_wep_deinit':
>  ieee80211_crypt_wep.c:(.text+0x90dd7): undefined reference to `crypto_free_tfm'
>  ieee80211_crypt_wep.c:(.text+0x90de3): undefined reference to `crypto_free_tfm'
>  net/built-in.o: In function `prism2_wep_init':
>  ieee80211_crypt_wep.c:(.text+0x90fab): undefined reference to `crypto_alloc_base'
>  ieee80211_crypt_wep.c:(.text+0x90fc9): undefined reference to `crypto_alloc_base'
>  ieee80211_crypt_wep.c:(.text+0x91007): undefined reference to `crypto_free_tfm'
>  ieee80211_crypt_wep.c:(.text+0x91031): undefined reference to `crypto_free_tfm'
>
> kernel v2.6.28-rc3-234-gfed4d59, config is attached.
>
>        Ingo
>
