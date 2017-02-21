From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio-net: switch to use build_skb() for
	small buffer
Date: Tue, 21 Feb 2017 12:26:33 -0500 (EST)
Message-ID: <20170221.122633.2147557584633743335.davem@davemloft.net>
References: <1487666788-9658-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1487666788-9658-1-git-send-email-jasowang@redhat.com>
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
Date: Tue, 21 Feb 2017 16:46:28 +0800

> This patch switch to use build_skb() for small buffer which can have
> better performance for both TCP and XDP (since we can work at page
> before skb creation). It also remove lots of XDP codes since both
> mergeable and small buffer use page frag during refill now.
> 
>                        Before   | After
> XDP_DROP(xdp1) 64B  :  11.1Mpps | 14.4Mpps
> 
> Tested with xdp1/xdp2/xdp_ip_tx_tunnel and netperf.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.
