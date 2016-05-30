From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v5 0/2] skb_array: array based FIFO for skbs
Date: Mon, 30 May 2016 18:37:05 +0300
Message-ID: <20160530183455-mutt-send-email-mst@redhat.com>
References: <1464000201-15560-1-git-send-email-mst@redhat.com>
 <574C0F05.1040500@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	brouer@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <574C0F05.1040500@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 30, 2016 at 05:59:33PM +0800, Jason Wang wrote:
>=20
>=20
> On 2016=E5=B9=B405=E6=9C=8823=E6=97=A5 18:43, Michael S. Tsirkin wrot=
e:
> >This is in response to the proposal by Jason to make tun
> >rx packet queue lockless using a circular buffer.
> >My testing seems to show that at least for the common usecase
> >in networking, which isn't lockless, circular buffer
> >with indices does not perform that well, because
> >each index access causes a cache line to bounce between
> >CPUs, and index access causes stalls due to the dependency.
>=20
> I change tun to use skb array, looks like it can give about 5% more f=
aster
> than skb ring.

OK and skb ring is 9% faster than the linked list, so together
this is a 14% speedup?

> And we usually don't need touch bhs during consume and produce (e.g f=
or the
> case of tun).
>=20
> Thanks

Maybe I'll drop it in v6 then ...
Could you post the full tun patchset please?

--=20
MST
