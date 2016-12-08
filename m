From: Bart Van Assche <Bart.VanAssche@sandisk.com>
Subject: Re: [PATCH] linux/types.h: enable endian checks for all sparse builds
Date: Thu, 8 Dec 2016 05:21:47 +0000
Message-ID: <BLUPR02MB168374E98A6C86E43DF0BCFE81840@BLUPR02MB1683.namprd02.prod.outlook.com>
References: <1481164052-28036-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Jason Wang <jasowang@redhat.com>,
        "linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>,
        Michal Marek <mmarek@suse.com>, Arnd Bergmann <arnd@arndb.de>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "Matt Mackall" <mpm@selenic.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David Airlie" <airlied@linux.ie>,
        Gerd Hoffmann <kraxel@redhat.com>,
        Ohad Ben-Cohen <ohad@wizery.com>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        "Cornelia Huck" <cornelia.huck@de.ibm.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        "Jens Axboe" <axboe@fb.com>,
        Neil Armstrong <narmstrong@baylibre.com>,
        "Stefan Hajnoczi" <stefanha@redhat.com>,
        Asias He <asias@redhat.com>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vg
To: "Michael S. Tsirkin" <mst@redhat.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Christoph Hellwig <hch@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/07/16 18:29, Michael S. Tsirkin wrote:=0A=
> By now, linux is mostly endian-clean. Enabling endian-ness=0A=
> checks for everyone produces about 200 new sparse warnings for me -=0A=
> less than 10% over the 2000 sparse warnings already there.=0A=
>=0A=
> Not a big deal, OTOH enabling this helps people notice=0A=
> they are introducing new bugs.=0A=
>=0A=
> So let's just drop __CHECK_ENDIAN__. Follow-up patches=0A=
> can drop distinction between __bitwise and __bitwise__.=0A=
=0A=
Hello Michael,=0A=
=0A=
This patch makes a whole bunch of ccflags-y +=3D -D__CHECK_ENDIAN__ =0A=
statements obsolete. Have you considered to remove these statements?=0A=
=0A=
Additionally, there are notable exceptions to the rule that most drivers =
=0A=
are endian-clean, e.g. drivers/scsi/qla2xxx. I would appreciate it if it =
=0A=
would remain possible to check such drivers with sparse without enabling =
=0A=
endianness checks. Have you considered to change #ifdef __CHECK_ENDIAN__ =
=0A=
into e.g. #ifndef __DONT_CHECK_ENDIAN__?=0A=
=0A=
Thanks,=0A=
=0A=
Bart.=0A=
