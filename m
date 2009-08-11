From: Eric Paris <eparis@parisplace.org>
Subject: Re: [RFC PATCH v2 2/2] selinux: Support for the new TUN LSM hooks
Date: Tue, 11 Aug 2009 16:36:22 -0400
Message-ID: <7e0fb38c0908111336uadf57efx7d87be7761c0e138@mail.gmail.com>
References: <20090810172238.7946.34247.stgit@flek.lan>
	 <20090810172850.7946.25175.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090810172850.7946.25175.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 10, 2009 at 1:28 PM, Paul Moore<paul.moore@hp.com> wrote:
> Add support for the new TUN LSM hooks: security_tun_dev_create(),
> security_tun_dev_post_create() and security_tun_dev_attach(). =A0This=
 includes
> the addition of a new object class, tun_socket, which represents the =
socks
> associated with TUN devices. =A0The _tun_dev_create() and _tun_dev_po=
st_create()
> hooks are fairly similar to the standard socket functions but _tun_de=
v_attach()
> is a bit special. =A0The _tun_dev_attach() is unique because it invol=
ves a
> domain attaching to an existing TUN device and its associated tun_soc=
ket
> object, an operation which does not exist with standard sockets and m=
ost
> closely resembles a relabel operation.

Looks good to me, feel free to add my Ack

-Eric
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
