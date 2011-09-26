From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/2] virtio-net: Verify page list size before fitting
 into skb
Date: Mon, 26 Sep 2011 22:57:17 +0300
Message-ID: <20110926195716.GB23086@redhat.com>
References: <1317058869-19276-1-git-send-email-levinsasha928@gmail.com>
 <20110926184445.GA22278@redhat.com>
 <1317065842.20885.3.camel@lappy>
 <CAOJsxLHQZCvRQMcs08GZgDgR9AwtePdr=t7kos6XfMF_dgxZGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sasha Levin <levinsasha928@gmail.com>,
	linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOJsxLHQZCvRQMcs08GZgDgR9AwtePdr=t7kos6XfMF_dgxZGw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 26, 2011 at 10:45:35PM +0300, Pekka Enberg wrote:
> On Mon, Sep 26, 2011 at 10:37 PM, Sasha Levin <levinsasha928@gmail.co=
m> wrote:
> >> Interesting. =A0This is a theoretical issue, correct?
> >> Not a crash you actually see.
> >
> > Actually it was an actual crash caused when our virtio-net driver i=
n kvm
> > tools did funny things and passed '(u32)-1' length as a buffer leng=
th to
> > the guest kernel.
>=20
> I'm not sure what Michael means with "theoretical issue" here. Can th=
e guest
> driver assume that the hypervisor doesn't attempt to do nasty things?
>=20
>                           Pekka

IMO yes, hypervisor has full access to guest memory so it's a safe
assumption. But surviving in the face of hypervisor bugs
is laudable goal, bugs do happen.

--=20
MST
