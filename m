From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: put virtio net header inline with data
Date: Wed, 17 Jul 2013 08:00:32 +0300
Message-ID: <20130717050032.GB10482@redhat.com>
References: <87vc4kcfzg.fsf@rustcorp.com.au>
	<20130709.213807.350021632586146971.davem@davemloft.net>
	<8761wc38ea.fsf@rustcorp.com.au>
	<20130716.123326.798365002638711260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davej@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20130716.123326.798365002638711260.davem@davemloft.net>
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

On Tue, Jul 16, 2013 at 12:33:26PM -0700, David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Mon, 15 Jul 2013 11:13:25 +0930
> 
> > From: Michael S. Tsirkin <mst@redhat.com>
> > 
> > For small packets we can simplify xmit processing
> > by linearizing buffers with the header:
> > most packets seem to have enough head room
> > we can use for this purpose.
> > Since existing hypervisors require that header
> > is the first s/g element, we need a feature bit
> > for this.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> I really think this has to wait until the next merge window, sorry.
> 
> Please resubmit this when I open net-next back up, thanks.

I assumed since -rc1 is out net-next is already open?
