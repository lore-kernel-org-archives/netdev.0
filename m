From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH for-3.7] vhost: fix mergeable bufs on BE hosts
Date: Wed, 24 Oct 2012 18:24:38 +0200
Message-ID: <20121024162437.GA10764@redhat.com>
References: <20121015175534.GA19489@redhat.com>
	<20121021124901.GA5315@redhat.com>
	<20121021.192402.1010682456837361393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20121021.192402.1010682456837361393.davem@davemloft.net>
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

On Sun, Oct 21, 2012 at 07:24:02PM -0400, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Sun, 21 Oct 2012 14:49:01 +0200
> 
> > On Mon, Oct 15, 2012 at 07:55:34PM +0200, Michael S. Tsirkin wrote:
> >> We copy head count to a 16 bit field,
> >> this works by chance on LE but on BE
> >> guest gets 0. Fix it up.
> >> 
> >> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> >> Tested-by: Alexander Graf <agraf@suse.de>
> >> Cc: stable@kernel.org
> > 
> > Ping. Dave, could you apply this to -net please?
> 
> Pinging me but not cc:'ing me?  That's really strange.
> 
> What if I operate by just mass deleting things that I'm
> not explicitly on the To: or CC: when I'm very backlogged?

Yes, that was silly. Would you like me to repost the patch?

-- 
MST
