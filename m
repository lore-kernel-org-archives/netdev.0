From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: util: mesh is not connected properly after
 recovery
Date: Wed, 29 Jun 2016 09:20:07 +0200
Message-ID: <1467184807.2461.5.camel@sipsolutions.net>
References: <20160628111546.8932-1-yanivma@ti.com>
	 (sfid-20160628_131320_130252_9109DD97)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Maital Hahn <maitalm@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Yaniv Machani <yanivma@ti.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160628111546.8932-1-yanivma@ti.com> (sfid-20160628_131320_130252_9109DD97)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-06-28 at 14:15 +0300, Yaniv Machani wrote:
> From: Maital Hahn <maitalm@ti.com>
> 
> In the reconfigure process for mesh interface, moved the
> reconfiguration
> of the mesh peers to be done only after restarting the beacons,
> the same as it is done for AP.
> 
> Signed-off-by: Maital Hahn <maitalm@ti.com>
> Acked-by: Yaniv Machani <yanivma@ti.com>
> 
Same here, and this also needs a description of why this is OK with
other drivers, since presumably it already works there.

johannes
