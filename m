From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v2 2/2] selinux: Support for the new TUN LSM hooks
Date: Wed, 12 Aug 2009 10:59:50 -0400
Message-ID: <200908121059.50167.paul.moore@hp.com>
References: <20090810172238.7946.34247.stgit@flek.lan> <20090810172850.7946.25175.stgit@flek.lan> <7e0fb38c0908111336uadf57efx7d87be7761c0e138@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Eric Paris <eparis@parisplace.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <7e0fb38c0908111336uadf57efx7d87be7761c0e138@mail.gmail.com>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 11 August 2009 04:36:22 pm Eric Paris wrote:
> On Mon, Aug 10, 2009 at 1:28 PM, Paul Moore<paul.moore@hp.com> wrote:
> > Add support for the new TUN LSM hooks: security_tun_dev_create(),
> > security_tun_dev_post_create() and security_tun_dev_attach().  This
> > includes the addition of a new object class, tun_socket, which represents
> > the socks associated with TUN devices.  The _tun_dev_create() and
> > _tun_dev_post_create() hooks are fairly similar to the standard socket
> > functions but _tun_dev_attach() is a bit special.  The _tun_dev_attach()
> > is unique because it involves a domain attaching to an existing TUN
> > device and its associated tun_socket object, an operation which does not
> > exist with standard sockets and most closely resembles a relabel
> > operation.
>
> Looks good to me, feel free to add my Ack

Thanks, I added both acks.

-- 
paul moore
linux @ hp

