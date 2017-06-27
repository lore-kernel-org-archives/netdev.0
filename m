From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] net: intel: e1000e: add check on
        e1e_wphy() return value
Date: Tue, 27 Jun 2017 01:21:59 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C6251E1@ORSMSX101.amr.corp.intel.com>
References: <20170518172223.Horde.5kLLwxMJWThQKv0bAxTsk4D@gator4166.hostgator.com>
 <20170620212234.GA10957@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170620212234.GA10957@embeddedgus>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@osuosl.org] On Behalf
> Of Gustavo A. R. Silva
> Sent: Tuesday, June 20, 2017 2:23 PM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Cc: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org; linux-
> kernel@vger.kernel.org; Gustavo A. R. Silva <garsilva@embeddedor.com>
> Subject: [Intel-wired-lan] [PATCH] net: intel: e1000e: add check on
> e1e_wphy() return value
> 
> Check return value from call to e1e_wphy(). This value is being
> checked during previous calls to function e1e_wphy() and it seems
> a check was missing here.
> 
> Addresses-Coverity-ID: 1226905
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> ---
>  drivers/net/ethernet/intel/e1000e/ich8lan.c | 2 ++
>  1 file changed, 2 insertions(+)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
