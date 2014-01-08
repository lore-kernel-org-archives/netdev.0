From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next v2 4/4] virtio-net: initial debugfs support,
	export mergeable rx buffer size
Date: Wed, 08 Jan 2014 14:34:31 +0800
Message-ID: <52CCF177.7020500@redhat.com>
References: <1389072355-20666-1-git-send-email-mwdalton@google.com>
	<1389072355-20666-4-git-send-email-mwdalton@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	virtualization@lists.linux-foundation.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Michael Dalton <mwdalton@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1389072355-20666-4-git-send-email-mwdalton@google.com>
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

On 01/07/2014 01:25 PM, Michael Dalton wrote:
> Add initial support for debugfs to virtio-net. Each virtio-net network
> device will have a directory under /virtio-net in debugfs. The
> per-network device directory will contain one sub-directory per active,
> enabled receive queue. If mergeable receive buffers are enabled, each
> receive queue directory will contain a read-only file that returns the
> current packet buffer size for the receive queue.
>
> Signed-off-by: Michael Dalton <mwdalton@google.com>

This looks more complicated than expected. How about just adding an
entry in sysfs onto the existed network class device which looks more
simpler?
