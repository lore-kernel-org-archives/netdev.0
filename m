From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] net/macvtap: add vhost suppor
Date: Mon, 15 Feb 2010 10:20:30 +0100
Message-ID: <201002151020.30127.arnd@arndb.de>
References: <201002131133.43028.arnd@arndb.de> <201002131135.08477.arnd@arndb.de> <20100214132732.GB31180@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ed Swierk <eswierk@aristanetworks.com>,
	Patrick McHardy <kaber@trash.net>,
	Sridhar Samudrala <sri@us.ibm.com>, qemu-devel@nongnu.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100214132732.GB31180@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 14 February 2010, Michael S. Tsirkin wrote:
> > @@ -473,7 +477,7 @@ static struct socket *get_socket(int fd)
> >       sock = get_raw_socket(fd);
> >       if (!IS_ERR(sock))
> >               return sock;
> > -     sock = get_tun_socket(fd);
> > +     sock = get_tap_socket(fd);
> >       if (!IS_ERR(sock))
> >               return sock;
> >       return ERR_PTR(-ENOTSOCK);
> 
> This will also need a dependency on macvtap in Kconfig.
> See how it's done for tun.

Ok, I'll add that.

Thanks,

	Arnd
