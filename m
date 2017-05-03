From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH net-next] igb: mark PM functions as
        __maybe_unused
Date: Wed, 3 May 2017 01:36:49 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C5F2BEB@ORSMSX101.amr.corp.intel.com>
References: <20170427191007.1990964-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "David S. Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170427191007.1990964-1-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Arnd Bergmann
> Sent: Thursday, April 27, 2017 12:10 PM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Cc: Arnd Bergmann <arnd@arndb.de>; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; intel-wired-lan@lists.osuosl.org; David S. Miller
> <davem@davemloft.net>
> Subject: [Intel-wired-lan] [PATCH net-next] igb: mark PM functions as
> __maybe_unused
> 
> The new wake function is only used by the suspend/resume handlers that
> are defined in inside of an #ifdef, which can cause this harmless
> warning:
> 
> drivers/net/ethernet/intel/igb/igb_main.c:7988:13: warning:
> 'igb_deliver_wake_packet' defined but not used [-Wunused-function]
> 
> Removing the #ifdef, instead using a __maybe_unused annotation
> simplifies the code and avoids the warning.
> 
> Fixes: b90fa8763560 ("igb: Enable reading of wake up packet")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 18 +++++-------------
>  1 file changed, 5 insertions(+), 13 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
