From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] virtio: Avoid virtio_net TX queue over run
Date: Thu, 17 Mar 2011 17:58:16 +0100
Message-ID: <1300381096.6315.315.camel@edumazet-laptop>
References: <1300320595.3255.29.camel@localhost.localdomain>
	 <20110317050538.GD32049@redhat.com>
	 <1300380626.3255.53.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1300380626.3255.53.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 17 mars 2011 =C3=A0 09:50 -0700, Shirley Ma a =C3=A9crit :
> On Thu, 2011-03-17 at 07:05 +0200, Michael S. Tsirkin wrote:
> > Could you add CPU utilization data pls? I also wonder what does thi=
s
> > do
> > to UDP?  Won't a lot of packets be dropped?
>=20
> Guest CPU utilization slightly increased a few %.
>=20
> UDP performance send rate increased 200% - 400%, recv rate increased
> from 10% to around 40% w/i recv errors. I will tune the buffers to se=
e
> any better.
>=20
> I am putting all data together and post the results here soon.

Could you run your tests with only one cpu ?
(offline all cpus but cpu0 on your hypervisor)

Dropping packets is fine, unless consumer cant run ;)



