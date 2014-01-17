From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio-net: drop rq->max and rq->num
Date: Thu, 16 Jan 2014 17:37:37 -0800 (PST)
Message-ID: <20140116.173737.429918297549548812.davem@davemloft.net>
References: <1389854724-48411-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1389854724-48411-1-git-send-email-jasowang@redhat.com>
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

From: Jason Wang <jasowang@redhat.com>
Date: Thu, 16 Jan 2014 14:45:24 +0800

> It looks like there's no need for those two fields:
> 
> - Unless there's a failure for the first refill try, rq->max should be always
>   equal to the vring size.
> - rq->num is only used to determine the condition that we need to do the refill,
>   we could check vq->num_free instead.
> - rq->num was required to be increased or decreased explicitly after each
>   get/put which results a bad API.
> 
> So this patch removes them both to make the code simpler.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Applied, thanks.
