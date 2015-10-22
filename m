From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/6] net: dsa: implement port_fdb_dump in
 drivers
Date: Thu, 22 Oct 2015 06:15:18 -0700 (PDT)
Message-ID: <20151022.061518.571868884904169741.davem@davemloft.net>
References: <1445357846-25720-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
	sfeldma@gmail.com, jiri@resnulli.us
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445357846-25720-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue, 20 Oct 2015 12:17:20 -0400

> Not all switch chips provide a Get Next kind of operation to dump FDB entries.
> It is preferred to let the driver handle the dump operation the way it works
> best for the chip. Thus, drop port_fdb_getnext and implement the port_fdb_dump
> operation in DSA, which pushes the switchdev FDB dump callback down to the
> drivers. mv88e6xxx is the only driver affected and is updated accordingly.
> 
> v2 -> v3: opencode switchdev_obj_dump_cb_t to avoid multiple typedef
> 
> v1 -> v2: fix a few "return err" instead of "goto unlock" in mv88e6xxx.c

This series gives rejects when I try to apply it to net-next, so please
respin.

Thanks.
