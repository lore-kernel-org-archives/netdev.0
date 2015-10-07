From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/5] net: dsa: complete and fix the dsa unbinding
Date: Wed, 07 Oct 2015 04:56:33 -0700 (PDT)
Message-ID: <20151007.045633.344434060767220177.davem@davemloft.net>
References: <5613DD2E.1070209@baylibre.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	fabf@skynet.be, pavel.nakonechny@skitlab.ru, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nbd@openwrt.org, sergei.shtylyov@cogentembedded.com
To: narmstrong@baylibre.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5613DD2E.1070209@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Armstrong <narmstrong@baylibre.com>
Date: Tue, 6 Oct 2015 15:39:42 +0100

> In order to cleanly unbind the dsa core, either as a module removal,
> or a platform device unbind, switch the allocation the their devm_
> counterparts and complete the destroy functions.
> 
> First, the missing kfree were added, the remove function were
> completed then kfree were removed in favor to devm_ calls.
> 
> The last patch is an way to cleanly exit the probe when no
> switch is found in the discover process.
> 
> The patches are based on the current net.
> 
> v3:
>  - make checkpatch happy with 1/5 & 5/5
>  - fix 5/5 exit path with a goto

Series applied, thanks Neil.
