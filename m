From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio-net: put virtio net header inline with data
Date: Tue, 16 Jul 2013 12:33:26 -0700 (PDT)
Message-ID: <20130716.123326.798365002638711260.davem@davemloft.net>
References: <87vc4kcfzg.fsf@rustcorp.com.au>
	<20130709.213807.350021632586146971.davem@davemloft.net>
	<8761wc38ea.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davej@redhat.com
To: rusty@rustcorp.com.au
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <8761wc38ea.fsf@rustcorp.com.au>
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

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Mon, 15 Jul 2013 11:13:25 +0930

> From: Michael S. Tsirkin <mst@redhat.com>
> 
> For small packets we can simplify xmit processing
> by linearizing buffers with the header:
> most packets seem to have enough head room
> we can use for this purpose.
> Since existing hypervisors require that header
> is the first s/g element, we need a feature bit
> for this.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

I really think this has to wait until the next merge window, sorry.

Please resubmit this when I open net-next back up, thanks.
