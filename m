From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next] qed*: Utilize Firmware 8.15.3.0
Date: Fri, 10 Mar 2017 05:44:05 +0000
Message-ID: <BL2PR07MB23065C5592BE9E8FF987717E8D200@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1489091851-1282-1-git-send-email-Yuval.Mintz@cavium.com>
 <20170309214557.GA16860@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
        "Tayar, Tomer" <Tomer.Tayar@cavium.com>,
        "Amrani, Ram" <Ram.Amrani@cavium.com>,
        "Rangankar, Manish" <Manish.Rangankar@cavium.com>,
        "Dupuis, Chad" <Chad.Dupuis@cavium.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0064.outbound.protection.outlook.com ([104.47.42.64]:22042
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750806AbdCJFoJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Mar 2017 00:44:09 -0500
In-Reply-To: <20170309214557.GA16860@infradead.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We can't just require a new firmware version in the driver, as users most
> likely won't have it by the time they install the new kernel.  So you'll =
have to
> support the old firmware version as well.

Why not? That has been the paradigm forever.

The new firmware version is already available in linux-firmware.
In any reasonable distro that would update the driver, you'd expect
they'd also update the firmware version on their filesystem.
