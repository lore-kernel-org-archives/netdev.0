From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 4/5] virtio_net: Add a MAC filter table
Date: Mon, 19 Jan 2009 09:33:05 +0000
Message-ID: <1232357585.5627.19.camel@blaa>
References: <20090116211312.22836.34331.stgit@debian.lart>
	 <20090116211334.22836.72681.stgit@debian.lart>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au, kvm@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090116211334.22836.72681.stgit@debian.lart>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-01-16 at 14:13 -0700, Alex Williamson wrote:
> Make use of the MAC_TABLE control virtqueue class to support a
> MAC filter table.  The size of the filter table defaults to 16
> entries and can be adjusted via the mac_entries module parameter.
> Note, the original hardware address does not count towards this.
> 
> As with most real hardware, unicast addresses have priority in
> the filter table so we can avoid enabling full promiscuous
> until both unicast and multicast address overflow.
> 
> Signed-off-by: Alex Williamson <alex.williamson@hp.com

Acked-by: Mark McLoughlin <markmc@redhat.com>

Cheers,
Mark.

