From: Madalin-cristian Bucur <madalin.bucur@nxp.com>
Subject: RE: [PATCH] fsl/fman: remove of_node
Date: Wed, 4 Oct 2017 09:53:39 +0000
Message-ID: <AM5PR0402MB2691AA6167F9C9A68C058797EC730@AM5PR0402MB2691.eurprd04.prod.outlook.com>
References: <1506940297-20442-1-git-send-email-madalin.bucur@nxp.com>
        <20171002.160445.737065995396076298.davem@davemloft.net>
        <AM5PR0402MB26914CBD37E3F28C17562258EC720@AM5PR0402MB2691.eurprd04.prod.outlook.com>
 <20171003.214357.2276688669726195045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171003.214357.2276688669726195045.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, October 04, 2017 7:44 AM
> To: Madalin-cristian Bucur <madalin.bucur@nxp.com>
> Cc: netdev@vger.kernel.org; andrew@lunn.ch; f.fainelli@gmail.com; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH] fsl/fman: remove of_node
>=20
> From: Madalin-cristian Bucur <madalin.bucur@nxp.com>
> Date: Tue, 3 Oct 2017 08:49:31 +0000
>=20
> > My patch removes the of_node that was set to a device that was not an
> > of_device, preventing duplicated probing of both the real of_device
> > and the "fake" one created through this assignment.
> >
> > I understand that the DSA issue that triggered the initial change
> > was related to DSA finding the network devices using
> > of_find_net_device_by_node(), something that will not work for the
> > DPAA case where the netdevice does not have an of_node. I do not know
> > enough about DSA to come up with a solution for this problem now.
> > Andrew, Florian, can you please comment on this?
>=20
> It sounds like you're knowingly breaking DSA.

It never worked, even with the change I'm reverting.
