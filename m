From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: zero is an invald queue_pairs number
Date: Tue, 22 Apr 2014 16:01:55 -0400 (EDT)
Message-ID: <20140422.160155.2054416620213198046.davem@davemloft.net>
References: <1397799941-11371-1-git-send-email-akong@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com,
	virtualization@lists.linux-foundation.org
To: akong@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1397799941-11371-1-git-send-email-akong@redhat.com>
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

From: Amos Kong <akong@redhat.com>
Date: Fri, 18 Apr 2014 13:45:41 +0800

> Execute "ethtool -L eth0 combined 0" in guest, if multiqueue
> is enabled, virtnet_send_command() will return -EINVAL error,
> there is a validation in QEMU.
> 
> But if multiqueue is disabled, virtnet_set_queues() will just
> return zero (success). We should return error for this situation.
> 
> Signed-off-by: Amos Kong <akong@redhat.com>

Applied, thanks.
