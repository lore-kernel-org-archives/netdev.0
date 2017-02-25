From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH] net: intel: e1000: use new api
 ethtool_{get|set}_link_ksettings
Date: Sat, 25 Feb 2017 02:19:57 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C5AB2A5@ORSMSX101.amr.corp.intel.com>
References: <1485011163-7402-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485011163-7402-1-git-send-email-tremyfr@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Philippe Reynes
> Sent: Saturday, January 21, 2017 7:06 AM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; davem@davemloft.net
> Cc: intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Philippe Reynes <tremyfr@gmail.com>
> Subject: [PATCH] net: intel: e1000: use new api
> ethtool_{get|set}_link_ksettings
> 
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> As I don't have the hardware, I'd be very pleased if
> someone may test this patch.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_ethtool.c |   93 +++++++++++---------
> --
>  1 files changed, 46 insertions(+), 47 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
