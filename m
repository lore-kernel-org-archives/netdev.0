From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: hyperv: use new api ethtool_{get|set}_link_ksettings
Date: Thu, 9 Mar 2017 14:51:14 -0800
Message-ID: <20170309145114.755fbff3@xeon-e3>
References: <1489012864-30810-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sthemmin@microsoft.com, netdev@vger.kernel.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
 davem@davemloft.net
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1489012864-30810-1-git-send-email-tremyfr@gmail.com>
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

On Wed,  8 Mar 2017 23:41:04 +0100
Philippe Reynes <tremyfr@gmail.com> wrote:

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

No change in behavior. Same as before driver always reports duplex UNKNOWN and speed change
is not useful.

Tested-by: Stephen Hemminger <sthemmin@microsoft.com>
