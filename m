From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/6] fsl/fman: enable FMan Keygen
Date: Tue, 22 Aug 2017 21:46:45 -0700 (PDT)
Message-ID: <20170822.214645.953115103494976385.davem@davemloft.net>
References: <1503423066-15420-2-git-send-email-madalin.bucur@nxp.com>
        <20170822.143510.1048652578169181274.davem@davemloft.net>
        <AM5PR0402MB2691CF2AC9555829EC89C59CEC850@AM5PR0402MB2691.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org
To: madalin.bucur@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM5PR0402MB2691CF2AC9555829EC89C59CEC850@AM5PR0402MB2691.eurprd04.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin-cristian Bucur <madalin.bucur@nxp.com>
Date: Wed, 23 Aug 2017 04:36:56 +0000

> The struct fman is only visible in the fman file, the fman port
> module uses struct fman as an opaque pointer, thus this export.

Don't use that programming model.

Export the datastructure properly to it's users.

This abstraction scheme is so wasteful and costly.
