From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V5] virtio-net: validate features during probe
Date: Fri, 21 Nov 2014 00:27:28 -0500 (EST)
Message-ID: <20141121.002728.487856666097568926.davem@davemloft.net>
References: <1416474185-10981-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1416474185-10981-1-git-send-email-jasowang@redhat.com>
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
Date: Thu, 20 Nov 2014 17:03:05 +0800

> We currently trigger BUG when VIRTIO_NET_F_CTRL_VQ
> is not set but one of features depending on it is.
> That's not a friendly way to report errors to
> hypervisors.
> Let's check, and fail probe instead.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
> Cc: Wanlong Gao <gaowanlong@cn.fujitsu.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks.
