From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next rfc v7 1/3] virtio-net: separate fields of
	sending/receiving queue from virtnet_info
Date: Mon, 3 Dec 2012 13:18:48 +0200
Message-ID: <20121203111848.GD26167@redhat.com>
References: <1354011360-39479-1-git-send-email-jasowang@redhat.com>
	<1354011360-39479-2-git-send-email-jasowang@redhat.com>
	<87y5hfj3vl.fsf@rustcorp.com.au>
	<3524590.ZWGua7A8ne@jason-thinkpad-t430s>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	bhutchings@solarflare.com, jwhan@filewood.snu.ac.kr, shiyer@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <3524590.ZWGua7A8ne@jason-thinkpad-t430s>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 03, 2012 at 01:15:01PM +0800, Jason Wang wrote:
> > > +
> 
> > > + /* Work struct for refilling if we run low on memory. */
> 
> > > + struct delayed_work refill;
> 
> >
> 
> > I can't really see the justificaiton for a refill per queue. Just have
> 
> > one work iterate all the queues if it happens, unless it happens often
> 
> > (in which case, we need to look harder at this anyway).
> 
>  
> 
> But during this kind of iteration, we may need enable/disable the napi
> regardless of whether the receive queue has lots to be refilled. This may add
> extra latency.

We are running from the timer, so latency is not a concern I think.

-- 
MST
