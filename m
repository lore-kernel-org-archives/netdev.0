From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 0/6] virtio-net: mergeable rx buffer size
	auto-tuning
Date: Thu, 16 Jan 2014 23:51:20 -0800 (PST)
Message-ID: <20140116.235120.414403159336172289.davem@davemloft.net>
References: <1389939810-14998-1-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	bhutchings@solarflare.com
To: mwdalton@google.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1389939810-14998-1-git-send-email-mwdalton@google.com>
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

From: Michael Dalton <mwdalton@google.com>
Date: Thu, 16 Jan 2014 22:23:24 -0800

> The virtio-net device currently uses aligned MTU-sized mergeable receive
> packet buffers. Network throughput for workloads with large average
> packet size can be improved by posting larger receive packet buffers.
> However, due to SKB truesize effects, posting large (e.g, PAGE_SIZE)
> buffers reduces the throughput of workloads that do not benefit from GRO
> and have no large inbound packets.
> 
> This patchset introduces virtio-net mergeable buffer size auto-tuning,
> with buffer sizes ranging from aligned MTU-size to PAGE_SIZE. Packet
> buffer size is chosen based on a per-receive queue EWMA of incoming
> packet size.
> 
> To unify mergeable receive buffer memory allocation and improve
> SKB frag coalescing, all mergeable buffer memory allocation is
> migrated to per-receive queue page frag allocators.
> 
> The per-receive queue mergeable packet buffer size is exported via
> sysfs, and the network device sysfs layer has been extended to add
> support for device-specific per-receive queue sysfs attribute groups.

Series applied, thanks.
