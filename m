From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost-net: initialize zcopy packet counters
Date: Mon, 03 Dec 2012 13:42:38 -0500 (EST)
Message-ID: <20121203.134238.1861170350026259675.davem@davemloft.net>
References: <20121203173151.GA30949@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121203173151.GA30949@redhat.com>
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

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 3 Dec 2012 19:31:51 +0200

> These packet counters are used to drive the zercopy
> selection heuristic so nothing too bad happens if they are off a bit -
> and they are also reset once in a while.
> But it's cleaner to clear them when backend is set so that
> we start in a known state.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied to net-next, thanks.
