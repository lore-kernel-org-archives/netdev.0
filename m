From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH] net: intel: e1000e: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 22 Feb 2017 03:27:16 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C5AA50D@ORSMSX101.amr.corp.intel.com>
References: <1485465593-12561-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:16729 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752806AbdBVD11 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Feb 2017 22:27:27 -0500
In-Reply-To: <1485465593-12561-1-git-send-email-tremyfr@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Philippe Reynes
> Sent: Thursday, January 26, 2017 1:20 PM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; davem@davemloft.net
> Cc: intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Philippe Reynes <tremyfr@gmail.com>
> Subject: [PATCH] net: intel: e1000e: use new api
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
>  drivers/net/ethernet/intel/e1000e/ethtool.c |   91 ++++++++++++++---------
> ---
>  1 files changed, 49 insertions(+), 42 deletions(-)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
