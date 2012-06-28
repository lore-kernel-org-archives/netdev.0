From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] virtio_net: allow to change mac when iface is
	running
Date: Thu, 28 Jun 2012 01:30:24 -0700 (PDT)
Message-ID: <20120628.013024.1284454300191873475.davem@davemloft.net>
References: <1340810866-1017-1-git-send-email-jpirko@redhat.com>
	<20120627.213046.1244710404799995026.davem@davemloft.net>
	<20120628063525.GA1520@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	brouer@redhat.com, mst@redhat.com
To: jpirko@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120628063525.GA1520@minipsycho.orion>
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
Date: Thu, 28 Jun 2012 08:35:25 +0200

> Thu, Jun 28, 2012 at 06:30:46AM CEST, davem@davemloft.net wrote:
>>It therefore probably makes sense to add a boolean arg which when true
>>elides the netif_running() check then fixup and audit every caller.
> 
> I was thinking about this. Maybe probably __eth_mac_addr() which does
> not have netif_running() check and eth_mac_addr() calling
> netif_running() check and __eth_mac_addr() after that.
> 
> What do you think?

Yes, sounds good.
