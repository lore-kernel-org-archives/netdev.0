From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next] liquidio: use meaningful names for IRQs
Date: Mon, 20 Mar 2017 08:26:08 +0000
Message-ID: <BL2PR07MB2306BA618DA5459D7BADFC838D3A0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20170313195804.GA1796@felix2.cavium.com>
 <20170316.202043.1747040871993595115.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>,
        "Chickles, Derek" <Derek.Chickles@cavium.com>,
        "Burla, Satananda" <Satananda.Burla@cavium.com>,
        Ricardo Farrington <Ricardo.Farrington@cavium.com>
To: David Miller <davem@davemloft.net>,
        "Manlunas, Felix" <Felix.Manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0040.outbound.protection.outlook.com ([104.47.42.40]:47872
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752564AbdCTI0N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 04:26:13 -0400
In-Reply-To: <20170316.202043.1747040871993595115.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >     2.  The IRQ name can only be specified at the time it is requested.
> >         It cannot be changed after that.

Is there any inherent difficulty in adding that capability?
I.e., to rename the IRQ's action & kthread.

It would allow drivers to re-name their IRQ names upon NETDEV_CHANGENAME.
