From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio_net: fix use after free
Date: Fri, 17 Oct 2014 12:20:11 +0300
Message-ID: <20141017092011.GA31313@redhat.com>
References: <1413378878-28118-1-git-send-email-mst@redhat.com>
	<20141015.164727.298073723527552510.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20141015.164727.298073723527552510.davem@davemloft.net>
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

On Wed, Oct 15, 2014 at 04:47:27PM -0400, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Wed, 15 Oct 2014 16:23:28 +0300
> 
> > You used __netif_subqueue_stopped but that seems to use
> > a slightly more expensive test_bit internally.
> 
> More expensive in what sense?  It should be roughly the same
> as "x & y" sans the volatile.

I really just meant volatile - this might prevent some compiler
optimizations. I have't actually checked the produced binary so
I don't know for sure.

> Anyways I'm ambivalent and I want to see this bug fixes, so I'll
> apply your patch.
> 
> Thanks!
