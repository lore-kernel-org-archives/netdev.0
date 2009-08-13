From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/2] vhost_net: a kernel-level virtio server
Date: Thu, 13 Aug 2009 15:45:00 +0200
Message-ID: <200908131545.00304.arnd@arndb.de>
References: <cover.1249930169.git.mst@redhat.com> <20090812172141.GA29966@redhat.com> <4A83167E.2080701@codemonkey.ws>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org,
	"Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A83167E.2080701@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 12 August 2009, Anthony Liguori wrote:
> At any rate, I'd like to see performance results before we consider 
> trying to reuse virtio code.

Yes, I agree. I'd also like to do more work on the macvlan extensions
to see if it works out without involving a socket. Passing the socket
into the vhost_net device is a nice feature of the current implementation
that we'd have to give up for something else (e.g. making the vhost
a real network interface that you can hook up to a bridge) if it were
to use virtio.

Unless I can come up with a solution that is clearly superior, I'm
taking back my objections on that part for now.

	Arnd <><
