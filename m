From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] staging: octeon: Call SET_NETDEV_DEV()
Date: Tue, 20 Dec 2016 22:20:20 -0500 (EST)
Message-ID: <20161220.222020.1448709395205678279.davem@davemloft.net>
References: <20161215011326.8852-1-f.fainelli@gmail.com>
 <d5cd5832-4402-2468-9d64-0a8d6e62d965@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, asbjorn@asbjorn.st, aaro.koskinen@iki.fi,
 netdev@vger.kernel.org, nevola@gmail.com, bhaktipriya96@gmail.com,
 jarod@redhat.com, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
 tremyfr@gmail.com
To: f.fainelli@gmail.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <d5cd5832-4402-2468-9d64-0a8d6e62d965@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 20 Dec 2016 17:02:37 -0800

> On 12/14/2016 05:13 PM, Florian Fainelli wrote:
>> The Octeon driver calls into PHYLIB which now checks for
>> net_device->dev.parent, so make sure we do set it before calling into
>> any MDIO/PHYLIB related function.
>> 
>> Fixes: ec988ad78ed6 ("phy: Don't increment MDIO bus refcount unless it's a different owner")
>> Reported-by: Aaro Koskinen <aaro.koskinen@iki.fi>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Greg, David, since this is a fix for a regression introduced in the net
> tree, it may make sense that David take it via his tree.

Since the change in question is in Linus's tree, it's equally valid
for Greg to take it as well.
