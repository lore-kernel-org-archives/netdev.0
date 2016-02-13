From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/4] net: dsa: pass bridge down to drivers
Date: Sat, 13 Feb 2016 10:42:51 -0800
Message-ID: <CAGVrzcb3Oxwr5qidP=cuOxW81wShmqKVEWs8k8hWcoCHe+T5CQ@mail.gmail.com>
References: <1455296981-27998-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1455296981-27998-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455296981-27998-3-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-02-12 9:09 GMT-08:00 Vivien Didelot <vivien.didelot@savoirfairelinux.com>:
> Some DSA drivers may or may not support multiple software bridges on top
> of an hardware switch.
>
> It is more convenient for them to access the bridge's net_device for
> finer configuration.
>
> Removing the need to craft and access a bitmask also simplifies the
> code.
>
> This patch changes the signature of bridge related functions, update DSA
> drivers, and removes dsa_slave_br_port_mask.

This is the specific patch that depends on the patch you mention in
your cover letter, I applied it anyway, ignored the rejects in the
mv88e6xxx driver since I wanted to test bcm_sf2 only and the hardware
is still programmed the same way before and after:

Tested-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!
