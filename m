From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH] vsock: only load vmci transport on VMware hypervisor by
 default
Date: Sat, 2 Sep 2017 06:25:29 +0000
Message-ID: <KL1P15301MB00084A9644FAF51453402458BF930@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
References: <20170817135559.GG5539@stefanha-x1.localdomain>
 <04460E3B-B213-4090-96CD-00CEEBE6AC32@vmware.com>
 <KL1P15301MB0008A67BF969A47309CFA992BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170818153716.GB17572@stefanha-x1.localdomain>
 <KL1P15301MB00083B1F5B70CBAB7C42BBD3BF800@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170822095437.GB16799@stefanha-x1.localdomain>
 <A6BE88A8-6E79-486E-821F-0D5C8B1B3034@vmware.com>
 <KL1P15301MB000812AD1EFB8A3986EC6277BF850@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <KL1P15301MB0008087A3EF0A8D037CC4D52BF9F0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <61AE41B3-D143-46D2-8C68-009B78AF12C8@vmware.com>
 <20170831115455.GP13619@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        KY Srinivasan <kys@microsoft.com>,
        "Haiyang Zhang" <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        George Zhang <georgezhang@vmware.com>,
        Michal Kubecek <mkubecek@suse.cz>, Asias He <asias@redhat.com>,
        Vitaly Kuznetsov <vkuznets@redhat.com>,
        "Cathy Avery" <cavery@redhat.com>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        "Rolf Neugebauer" <rolf.neugebauer@docker.com>,
        Dave Scott <dave.scott@docker.com>,
        Marcelo Cerri <marcelo.cerri@canonical.com>,
        "apw@canonical.com" <apw@canonical.com>,
        "olaf@aepfle.de" <olaf@aepfle.de>,
To: Stefan Hajnoczi <stefanha@redhat.com>,
        "Jorgen S. Hansen" <jhansen@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170831115455.GP13619@stefanha-x1.localdomain>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Stefan Hajnoczi [mailto:stefanha@redhat.com]
> Sent: Thursday, August 31, 2017 4:55 AM
> ...
> On Tue, Aug 29, 2017 at 03:37:07PM +0000, Jorgen S. Hansen wrote:
> > > On Aug 29, 2017, at 4:36 AM, Dexuan Cui <decui@microsoft.com> wrote:
> > If we allow multiple host side transports, virtio host side support and
> > vmci should be able to coexist regardless of the order of initializatio=
n.
>=20
> That sounds good to me.
>=20
> This means af_vsock.c needs to be aware of CID allocation.  Currently the
> vhost_vsock.ko driver handles this itself (it keeps a list of CIDs and
> checks that they are not used twice).  It should be possible to move
> that state into af_vsock.c so we have <cid, host_transport> pairs.
>=20
> I'm currently working on NFS over AF_VSOCK and sock_diag support (for
> ss(8) and netstat-like tools).
>=20
> Multi-transport support is lower priority for me at the moment.  I'm
> happy to review patches though.  If there is no progress on this by the
> end of the year then I will have time to work on it.
I understand. Thank you both for sharing the details about the plan!
=20
> Are either of you are in Prague, Czech Republic on October 25-27 for
> Linux Kernel Summit, Open Source Summit Europe, Embedded Linux
> Conference Europe, KVM Forum, or MesosCon Europe?
>=20
> Stefan
I regret I won't be there this year.=20

Thanks,
-- Dexuan
