From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2] virtio-net: alloc big buffers also when guest
	can receive UFO
Date: Mon, 24 Feb 2014 18:20:41 -0500 (EST)
Message-ID: <20140224.182041.1959352738873712711.davem@davemloft.net>
References: <1392959284-11399-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, sri@us.ibm.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1392959284-11399-1-git-send-email-jasowang@redhat.com>
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
Date: Fri, 21 Feb 2014 13:08:04 +0800

> We should alloc big buffers also when guest can receive UFO
> pakcets to let the big packets be fit into guest rx buffer.
> 
> Fixes 5c5167515d80f78f6bb538492c423adcae31ad65
> (virtio-net: Allow UFO feature to be set and advertised.)
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Sridhar Samudrala <sri@us.ibm.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> Changes from V1:
> - tweak the commit log

Applied with commit message fixes, thanks.
