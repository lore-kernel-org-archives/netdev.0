From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] virtio_net: allow to change mac when iface is
	running
Date: Wed, 27 Jun 2012 21:30:46 -0700 (PDT)
Message-ID: <20120627.213046.1244710404799995026.davem@davemloft.net>
References: <1340810866-1017-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	brouer@redhat.com, mst@redhat.com
To: jpirko@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1340810866-1017-1-git-send-email-jpirko@redhat.com>
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

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 27 Jun 2012 17:27:46 +0200

> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, but this seriously makes eth_mac_addr() completely useless.

Technically, every eth_mac_addr() user in a software/virtual device
should behave the way virtio_net does now.

It therefore probably makes sense to add a boolean arg which when true
elides the netif_running() check then fixup and audit every caller.
