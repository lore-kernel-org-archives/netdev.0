From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-next-2.6 v2] virtio_net: missing sg_init_table
Date: Wed, 31 Mar 2010 03:16:36 -0700 (PDT)
Message-ID: <20100331.031636.04083770.davem@davemloft.net>
References: <4BB10010.5060505@mathtm.de>
	<1269911955.14013.4.camel@localhost.localdomain>
	<20100331092022.GA31911@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mashirle@us.ibm.com, thomas@mathtm.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100331092022.GA31911@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 31 Mar 2010 12:20:22 +0300

> On Mon, Mar 29, 2010 at 06:19:15PM -0700, Shirley Ma wrote:
>> Add missing sg_init_table for sg_set_buf in virtio_net which
>> induced in defer skb patch.
>>=20
>> Reported-by: Thomas M=FCller <thomas@mathtm.de>
>> Tested-by: Thomas M=FCller <thomas@mathtm.de>
>> Signed-off-by: Shirley Ma <xma@us.ibm.com>
>=20
> I'm concerned that the 'big' path might cause a performance regressio=
n.
> Let's move sg into virtnet_info so that this needs to be only called
> once?

Yeah that might improve things.

Shirley's change is already in net-next-2.6 so anything implementing
this would need to be submitted relative to that.
