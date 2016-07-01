From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V4 0/6] switch to use tx skb array in tun
Date: Fri, 01 Jul 2016 05:40:03 -0400 (EDT)
Message-ID: <20160701.054003.1169513351817423544.davem@davemloft.net>
References: <1467269136-8082-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, eric.dumazet@gmail.com, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, brouer@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1467269136-8082-1-git-send-email-jasowang@redhat.com>
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
Date: Thu, 30 Jun 2016 14:45:30 +0800

> This series tries to switch to use skb array in tun. This is used to
> eliminate the spinlock contention between producer and consumer. The
> conversion was straightforward: just introdce a tx skb array and use
> it instead of sk_receive_queue.

Series applied, thanks Jason.
