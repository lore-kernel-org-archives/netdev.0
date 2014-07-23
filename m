From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/2] rx busy polling support for virtio-net
Date: Wed, 23 Jul 2014 15:12:52 -0700 (PDT)
Message-ID: <20140723.151252.513994964059108010.davem@davemloft.net>
References: <1406104435-24077-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1406104435-24077-1-git-send-email-jasowang@redhat.com>
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
Date: Wed, 23 Jul 2014 16:33:53 +0800

> This series introduces the support for rx busy polling support. This
> was useful for reduing the latency for a kvm guest. Instead of
> introducing new states and spinlocks, this series re-uses NAPI state
> to synchonrize between NAPI and busy polling. This grealy simplified
> the codes and reduce the overheads of spinlocks for normal NAPI fast
> path.
> 
> Test was done between a kvm guest and an external host. Two hosts were
> connected through 40gb mlx4 cards. With both busy_poll and  busy_read
> are set to 50 in guest, 1 byte netperf tcp_rr shows 127% improvement:
> transaction rate was increased from 8353.33 to 18966.87.
> 
> Changes from V2:
> - Avoid introducing new states and spinlocks by reusuing the NAPI
>   state
> - Fix the budget calculation in virtnet_poll()
> - Drop patch 1/3 from V2 since it was useless
> 
> Changes from V1:
> - split the patch info smaller ones
> - add more details about test setup/configuration

Series applied, thanks Jason.
