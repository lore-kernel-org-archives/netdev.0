From: Bart Van Assche <Bart.VanAssche@sandisk.com>
Subject: Re: net/smc and the RDMA core
Date: Mon, 1 May 2017 17:29:38 +0000
Message-ID: <1493659776.2665.7.camel@sandisk.com>
References: <20170501163311.GA22209@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
To: "hch@lst.de" <hch@lst.de>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "ubraun@linux.vnet.ibm.com" <ubraun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.hgst.iphmx.com ([68.232.143.124]:22887 "EHLO
        esa2.hgst.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750839AbdEAR3l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 13:29:41 -0400
In-Reply-To: <20170501163311.GA22209@lst.de>
Content-Language: en-US
Content-ID: <B7D4EE88D8FC1E4AAD1D128B1471A0C5@namprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-05-01 at 18:33 +0200, Christoph Hellwig wrote:
> Hi Ursual, hi netdev reviewers,
>=20
> how did the smc protocol manage to get merged without any review=20
> on linux-rdma at all?  As the results it seems it's very substandard
> in terms of RDMA API usage, e.g. it neither uses the proper CQ API
> nor the RDMA R/W API, and other will probably find additional issues
> as well.

Hello Dave and Ursula,

It seems very rude to me to have merged the SMC protocol driver without
having involved the linux-rdma community. Anyway, I have the following
questions for Dave and Ursula:
* Since the Linux kernel is standards based: where can we find the standard
  that defines the SMC wire protocol? If this protocol has not been
  standardized yet: in what file (other than *.[ch]) in the Linux kernel
  tree has this protocol been documented?
* What are the differences between the SMC protocol, the SDP protocol and
  the rsockets protocol? How do existing implementations for these protocol=
s
  compare to each other from a performance point of view? If no performance
  comparison between these protocols is available, shouldn't the performanc=
e
  of these protocols have been compared with each other before a review of
  the SMC driver even started?
* What are the reasons why the SDP driver was never accepted upstream? Do
  the arguments why SDP was not accepted upstream also apply to the SMC
  driver (SDP =3D Sockets Direct Protocol)?
* Since SMC has to be selected by specifying AF_SMC, how are users expected
  to specify whether AF_INET, AF_INET6 or yet another address family should
  be used to set up a connection between SMC
endpoints?
* Is the SMC driver limited to RoCE? Are you aware that the rsockets librar=
y
  supports multiple transport layers (RoCE, IB and iWARP)?
* Since functionality that is similar what the SMC driver provides already
  exists in user space (rsockets), why has this functionality been
  reimplemented as a kernel driver (SMC)?

Bart.=
