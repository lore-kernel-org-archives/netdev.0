From: Bart Van Assche <Bart.VanAssche@sandisk.com>
Subject: Re: net/smc and the RDMA core
Date: Tue, 2 May 2017 15:37:07 +0000
Message-ID: <1493739426.2552.1.camel@sandisk.com>
References: <20170501163311.GA22209@lst.de>
         <1493659776.2665.7.camel@sandisk.com>
         <HE1PR0502MB30048AFD086C4B0D535BFC52D1140@HE1PR0502MB3004.eurprd05.prod.outlook.com>
         <dec979a3-a708-a814-ee99-777953fa4a4f@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
To: "hch@lst.de" <hch@lst.de>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "parav@mellanox.com" <parav@mellanox.com>,
        "ubraun@linux.vnet.ibm.com" <ubraun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa3.hgst.iphmx.com ([216.71.153.141]:20311 "EHLO
        esa3.hgst.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdEBPhK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:37:10 -0400
In-Reply-To: <dec979a3-a708-a814-ee99-777953fa4a4f@linux.vnet.ibm.com>
Content-Language: en-US
Content-ID: <3F299F14F648384182E3788903D885C8@namprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-05-02 at 14:41 +0200, Ursula Braun wrote:
> On 05/01/2017 07:55 PM, Parav Pandit wrote:
> > Hi Bart, Ursula, Dave,
> >=20
> > I am particularly concerned about SMC as address family.
> > It should not be treated as address family, but rather an additional
> > protocol similar for socket type SOCK_STREAM.
>=20
> We tried to avoid changes of the kernel TCP code. A new address family
> seemed to be a feasible way to achieve this.

Hello Ursula,

I agree with Parav that introducing a new address family for SMC was an
unfortunate choice. As one can see in e.g. the implementation of the SCTP
protocol no changes to the TCP implementation are needed to add support
for a new SOCK_STREAM protocol. I think the SCTP implementation uses
inet_register_protosw() to register itself dynamically.

Bart.=
