From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Change dev->needed_headroom of virtio_net to make
 Patch"virtio-net: put virtio net header inline with data"work better
Date: Thu, 24 Apr 2014 14:44:57 +0300
Message-ID: <20140424114457.GB16979@redhat.com>
References: <60A73B7A161A82449A7DB7B382BFD15537026EF3@SZXEMA504-MBS.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "jasowang@redhat.com" <jasowang@redhat.com>,
	Qinchuanyu <qinchuanyu@huawei.com>,
	Liuyongan <liuyongan@huawei.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: "Zhangjie (HZ)" <zhangjie14@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39896 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753503AbaDXLoc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2014 07:44:32 -0400
Content-Disposition: inline
In-Reply-To: <60A73B7A161A82449A7DB7B382BFD15537026EF3@SZXEMA504-MBS.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2014 at 10:19:58AM +0000, Zhangjie (HZ) wrote:
> Hi!
>=20
> Patch =E2=80=9Cvirtio-net: put virtio net header inline with data=E2=80=
=9D , has a notable
> improvement for TCP packages.
>=20
> But UDP packages from virtio_net nic, do not have enough head room. I=
 wonder if
> we can set dev->needed_headroom
>=20
> to the size of virtio net header, so as to put the header in. By doin=
g this,
> udp get about 5% improvement in bandwidth.

Sounds like a reasonable thing to do.
Want to post the patch so people can try it out?

> =20
>=20
> --
>=20
> Thanks,
>=20
> //Zhang Jie
>=20
> =20
>=20
