From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC] [PATCH] virtio: Dont add "config" to list for !per_vq_vector
Date: Thu, 06 Oct 2011 11:01:00 +1030
Message-ID: <87wrcjezaz.fsf@rustcorp.com.au>
References: <20111005053859.5825.1089.sendpatchset@krkumar2.in.ibm.com> <20111005104822.GC5587@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111005104822.GC5587@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 5 Oct 2011 08:48:23 -0200, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> On Wed, Oct 05, 2011 at 11:08:59AM +0530, Krishna Kumar wrote:
> > For the MSI but non-per_vq_vector case, the config/change vq
> > also gets added to the list of vqs that need to process the
> > MSI interrupt. This is not needed as config has it's own
> > handler (vp_config_changed). In any case, vring_interrupt()
> > finds nothing needs to be done on this vq.
> > 
> > I tested this patch by testing the "Fallback:" and "Finally
> > fall back" cases in vp_find_vqs(). Please review.
> > 
> > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> (note: this is not a bugfix so not 3.1 material).

Thanks, applied.

Cheers,
Rusty.
