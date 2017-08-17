From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH] vsock: only load vmci transport on VMware hypervisor by
 default
Date: Thu, 17 Aug 2017 18:27:30 +0000
Message-ID: <KL1P15301MB0008BBAEBF60A852EA629A9ABF830@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
References: <KL1P15301MB0008F70D4E5248AB7A296CE3BF830@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
 <20170817.100401.864010589587308706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "jhansen@vmware.com" <jhansen@vmware.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        KY Srinivasan <kys@microsoft.com>,
        "Haiyang Zhang" <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        "georgezhang@vmware.com" <georgezhang@vmware.com>,
        "mkubecek@suse.cz" <mkubecek@suse.cz>,
        "asias@redhat.com" <asias@redhat.com>,
        "stefanha@redhat.com" <stefanha@redhat.com>,
        "vkuznets@redhat.com" <vkuznets@redhat.com>,
        "cavery@redhat.com" <cavery@redhat.com>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        "rolf.neugebauer@docker.com" <rolf.neugebauer@docker.com>,
        "dave.scott@docker.com" <dave.scott@docker.com>,
        "marcelo.cerri@can
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170817.100401.864010589587308706.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, August 17, 2017 10:04
> I would avoid module parameters at all costs.
>=20
> It is the worst possible interface for users of your software.
>=20
> You really need to fundamentally solve the problems related to making
> sure the proper modules for the VM actually present on the system get
> loaded when necessary rather than adding hacks like this.
>=20
> Unlike a proper solution, these hacks are ugly but have to stay around
> forever once you put them in place.

Sorry for reminding me again, David! :-)

I'll try to figure out the correct solution.

Thanks,
-- Dexuan
