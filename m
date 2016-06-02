From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 0/2] vhost_net polling optimization
Date: Thu, 02 Jun 2016 12:08:06 -0700 (PDT)
Message-ID: <20160602.120806.2233781548139724198.davem@davemloft.net>
References: <1464760594-30326-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1464760594-30326-1-git-send-email-jasowang@redhat.com>
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
Date: Wed,  1 Jun 2016 01:56:32 -0400

> This series tries to optimize vhost_net polling at two points:
> 
> - Stop rx polling for reduicng the unnecessary wakeups during
>   handle_rx().
> - Conditonally enable tx polling for reducing the unnecessary
>   traversing and spinlock touching.
> 
> Test shows about 17% improvement on rx pps.
> 
> Please review
> 
> Changes from V2:
> - Don't enable rx vq if we meet an err or rx vq is empty
> Changes from V1:
> - use vhost_net_disable_vq()/vhost_net_enable_vq() instead of open
>   coding.
> - Add a new patch for conditionally enable tx polling.

Michael, please review this patch series.

Thanks.
