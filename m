From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] virtio_net: fix error handling for mergeable
	buffers
Date: Sun, 01 Dec 2013 20:27:52 -0500 (EST)
Message-ID: <20131201.202752.1283570881734672398.davem@davemloft.net>
References: <1385638044-27467-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mwdalton@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1385638044-27467-1-git-send-email-mst@redhat.com>
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
Date: Thu, 28 Nov 2013 13:30:55 +0200

> Eric Dumazet noticed that if we encounter an error
> when processing a mergeable buffer, we don't
> dequeue all of the buffers from this packet,
> the result is almost sure to be loss of networking.
> 
> Jason Wang noticed that we also leak a page and that we don't decrement
> the rq buf count, so we won't repost buffers (a resource leak).
> 
> Fix both issues.
> 
> Cc: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Michael Dalton <mwdalton@google.com>
> Reported-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Jason Wang <jasowang@redhat.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied.
