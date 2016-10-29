From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] virtio-net: Update the mtu code to match
	virtio spec
Date: Sat, 29 Oct 2016 12:01:02 -0400 (EDT)
Message-ID: <20161029.120102.2254330014511044545.davem@davemloft.net>
References: <1477426332-31093-1-git-send-email-aconole@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jarod@redhat.com, netdev@vger.kernel.org, mst@redhat.com,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: aconole@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1477426332-31093-1-git-send-email-aconole@redhat.com>
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

From: Aaron Conole <aconole@redhat.com>
Date: Tue, 25 Oct 2016 16:12:12 -0400

> The virtio committee recently ratified a change, VIRTIO-152, which
> defines the mtu field to be 'max' MTU, not simply desired MTU.
> 
> This commit brings the virtio-net device in compliance with VIRTIO-152.
> 
> Additionally, drop the max_mtu branch - it cannot be taken since the u16
> returned by virtio_cread16 will never exceed the initial value of
> max_mtu.
> 
> Signed-off-by: Aaron Conole <aconole@redhat.com>
> Acked-by: "Michael S. Tsirkin" <mst@redhat.com>
> Acked-by: Jarod Wilson <jarod@redhat.com>
> ---
> Nothing code-wise has changed, but I've included the ACKs and fixed up the
> subject line.

Applied, thanks.
