From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio: use __GFP_NOWARN for try_fill_recv in virtnet_poll
Date: Tue, 15 Feb 2011 20:41:29 +1030
Message-ID: <201102152041.29179.rusty@rustcorp.com.au>
References: <20110215093527.GB8341@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Michal Hocko <mhocko@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110215093527.GB8341@tiehlicka.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Feb 2011 08:05:27 pm Michal Hocko wrote:
> Hi,
> we have started seeing a lot of allocator messages complaining about
> failed allocations from virtnet_poll in soft IRQ. Could you consider the
> following patch, please?

Do we really want to silence this?  Isn't warning about it kind of the
point?  Your network is probably sucking if this happens...

Cheers,
Rusty.
