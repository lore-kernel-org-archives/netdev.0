From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH 1/1] ixgbe: add the external ixgbe fiber transceiver
 status
Date: Thu, 9 Feb 2017 19:08:43 +0000
Message-ID: <87618083B2453E4A8714035B62D679925074E73F@FMSMSX105.amr.corp.intel.com>
References: <1486609408-6770-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Zhu Yanjun <yanjun.zhu@oracle.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "broonie@kernel.org" <broonie@kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:3967 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751235AbdBITMd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 14:12:33 -0500
In-Reply-To: <1486609408-6770-1-git-send-email-yanjun.zhu@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Zhu Yanjun
>Sent: Wednesday, February 08, 2017 7:03 PM
>To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; broonie@kernel.org;
>davem@davemloft.net; intel-wired-lan@lists.osuosl.org;
>netdev@vger.kernel.org
>Subject: [PATCH 1/1] ixgbe: add the external ixgbe fiber transceiver status
>
>When the ixgbe fiber transceiver is external, it is necessary to get
>the present/absent status of this external ixgbe fiber transceiver.

The transceiver field was deprecated in the old ethtool API and is being
removed in the new. This patch will not apply at all once those changes are made:

http://patchwork.ozlabs.org/patch/725081/

Thanks,
Emil 
 
