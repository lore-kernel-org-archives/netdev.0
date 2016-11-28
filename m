From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio-net: enable multiqueue by default
Date: Mon, 28 Nov 2016 13:18:05 -0500 (EST)
Message-ID: <20161128.131805.1395686082038152344.davem@davemloft.net>
References: <1480048646-17536-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, jeder@redhat.com, hannes@redhat.com,
	netdev@vger.kernel.org, mst@redhat.com, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, myllynen@redhat.com,
	maxime.coquelin@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1480048646-17536-1-git-send-email-jasowang@redhat.com>
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
Date: Fri, 25 Nov 2016 12:37:26 +0800

> We use single queue even if multiqueue is enabled and let admin to
> enable it through ethtool later. This is used to avoid possible
> regression (small packet TCP stream transmission). But looks like an
> overkill since:
> 
> - single queue user can disable multiqueue when launching qemu
> - brings extra troubles for the management since it needs extra admin
>   tool in guest to enable multiqueue
> - multiqueue performs much better than single queue in most of the
>   cases
> 
> So this patch enables multiqueue by default: if #queues is less than or
> equal to #vcpu, enable as much as queue pairs; if #queues is greater
> than #vcpu, enable #vcpu queue pairs.
> 
> Cc: Hannes Frederic Sowa <hannes@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Neil Horman <nhorman@redhat.com>
> Cc: Jeremy Eder <jeder@redhat.com>
> Cc: Marko Myllynen <myllynen@redhat.com>
> Cc: Maxime Coquelin <maxime.coquelin@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks Jason.
