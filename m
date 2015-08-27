From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio-net: avoid unnecessary sg initialzation
Date: Thu, 27 Aug 2015 15:52:10 -0700 (PDT)
Message-ID: <20150827.155210.1669360284386445387.davem@davemloft.net>
References: <1440658386-9544-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1440658386-9544-1-git-send-email-jasowang@redhat.com>
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
Date: Thu, 27 Aug 2015 14:53:06 +0800

> Usually an skb does not have up to MAX_SKB_FRAGS frags. So no need to
> initialize the unuse part of sg. This patch initialize the sg based on
> the real number it will used:
> 
> - during xmit, it could be inferred from nr_frags and can_push.
> - for small receive buffer, it will also be 2.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

This looks fine, thanks Jason.
