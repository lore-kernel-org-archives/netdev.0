From: Bart Van Assche <Bart.VanAssche@sandisk.com>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Thu, 11 May 2017 14:57:43 +0000
Message-ID: <1494514662.2489.1.camel@sandisk.com>
References: <20170510072627.12060-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>,
        "ubraun@linux.vnet.ibm.com" <ubraun@linux.vnet.ibm.com>
To: "hch@lst.de" <hch@lst.de>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.hgst.iphmx.com ([68.232.143.124]:40639 "EHLO
        esa2.hgst.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932514AbdEKO5r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 10:57:47 -0400
In-Reply-To: <20170510072627.12060-1-hch@lst.de>
Content-Language: en-US
Content-ID: <71188D6E1FAAF24AA77D97D83BC075C9@namprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-05-10 at 09:26 +0200, Christoph Hellwig wrote:
> The driver has a lot of quality issues due to the lack of RDMA-side
> review, and explicitly bypasses APIs to register all memory once a
> connection is made, and thus allows remote access to memoery.
>=20
> Mark it as broken until at least that part is fixed.

Since this is the only way to get the BROKEN marker in the v4.11 stable
kernel series:

Acked-by: Bart Van Assche <bart.vanassche@sandisk.com>=
