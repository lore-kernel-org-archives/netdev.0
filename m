From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost_net: remove tx polling state
Date: Thu, 07 Mar 2013 16:25:16 -0500 (EST)
Message-ID: <20130307.162516.39680676875980781.davem@davemloft.net>
References: <1362630716-57674-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1362630716-57674-1-git-send-email-jasowang@redhat.com>
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
Date: Thu,  7 Mar 2013 12:31:56 +0800

> After commit 2b8b328b61c799957a456a5a8dab8cc7dea68575 (vhost_net: handle polling
> errors when setting backend), we in fact track the polling state through
> poll->wqh, so there's no need to duplicate the work with an extra
> vhost_net_polling_state. So this patch removes this and make the code simpler.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Can I get an ACK or two from some VHOST folks?
