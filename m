From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] net: dsa: push switchdev prepare phase in
 FDB ops
Date: Thu, 08 Oct 2015 05:28:39 -0700 (PDT)
Message-ID: <20151008.052839.1028977184279787835.davem@davemloft.net>
References: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, sfeldma@gmail.com, jiri@resnulli.us,
	f.fainelli@gmail.com, andrew@lunn.ch, narmstrong@baylibre.com,
	sergei.shtylyov@cogentembedded.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed,  7 Oct 2015 19:48:25 -0400

> The first 3 patches removes the dsa.h include from linux/netdevice.h, which
> broke the inclusion of switchdev.h in dsa.h.

I still don't agree with bloating up struct netdevice just to deal with
an include file ordering issue, sorry.
