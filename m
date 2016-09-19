From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH] ixgbe: mark symbols static where possible
Date: Mon, 19 Sep 2016 16:57:37 +0000
Message-ID: <87618083B2453E4A8714035B62D67992506E6E36@FMSMSX105.amr.corp.intel.com>
References: <1474188454-8872-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "arnd@arndb.de" <arnd@arndb.de>,
        "xie.baoyou@zte.com.cn" <xie.baoyou@zte.com.cn>
To: Baoyou Xie <baoyou.xie@linaro.org>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474188454-8872-1-git-send-email-baoyou.xie@linaro.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Baoyou Xie
>Sent: Sunday, September 18, 2016 1:48 AM
>To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; intel-wired-
>lan@lists.osuosl.org
>Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; arnd@arndb.de;
>baoyou.xie@linaro.org; xie.baoyou@zte.com.cn
>Subject: [PATCH] ixgbe: mark symbols static where possible
>
>We get 2 warnings when building kernel with W=1:
>drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c:2128:5: warning: no previous
>prototype for 'ixgbe_led_on_t_x550em' [-Wmissing-prototypes]
>drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c:2150:5: warning: no previous
>prototype for 'ixgbe_led_off_t_x550em' [-Wmissing-prototypes]

Already taken care of:
http://patchwork.ozlabs.org/patch/661647/

Thanks,
Emil
