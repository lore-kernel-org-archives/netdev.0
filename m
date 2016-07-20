From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 00/12] net: dsa: mv88e6xxx: Global2 cleanup
 and STP
Date: Tue, 19 Jul 2016 19:42:20 -0700 (PDT)
Message-ID: <20160719.194220.1605569742108600970.davem@davemloft.net>
References: <20160719004540.1066-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch, f.fainelli@gmail.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160719004540.1066-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon, 18 Jul 2016 20:45:28 -0400

> The Marvell switches registers are organized in distinct internal SMI
> devices, such as PHY, Port, Global 1 or Global 2 registers sets.
> 
> Since not all chips support every registers sets or have slightly
> differences in them (such as old 88E6060 or new 88E6390 likely to be
> supported soon), make the setup code clearer now by removing a few
> family checks and adding flags to describe the Global 2 registers map.
> 
> This patchset enables basic STP support and bridging on most chips when
> getting rid of a few inconsistencies in chip descriptions (patch 1) and
> add bridge Ageing Time support to DSA and the mv88e6xxx driver.

Series applied.
