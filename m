From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] net: intel: igbvf: use new api
        ethtool_{get|set}_link_ksettings
Date: Tue, 14 Mar 2017 01:46:28 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C5B3FF3@ORSMSX101.amr.corp.intel.com>
References: <1486335319-16273-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486335319-16273-1-git-send-email-tremyfr@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Philippe Reynes
> Sent: Sunday, February 5, 2017 2:55 PM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; davem@davemloft.net
> Cc: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org; linux-
> kernel@vger.kernel.org; Philippe Reynes <tremyfr@gmail.com>
> Subject: [Intel-wired-lan] [PATCH] net: intel: igbvf: use new api
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
>  drivers/net/ethernet/intel/igbvf/ethtool.c |   38 ++++++++++++++--------------
>  1 files changed, 19 insertions(+), 19 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
