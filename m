From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vhost: validate vhost_get_vq_desc return value
Date: Fri, 28 Mar 2014 16:11:08 -0400 (EDT)
Message-ID: <20140328.161108.883291931619730975.davem@davemloft.net>
References: <1395917517-30937-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1395917517-30937-1-git-send-email-mst@redhat.com>
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
Date: Thu, 27 Mar 2014 12:53:37 +0200

> vhost fails to validate negative error code
> from vhost_get_vq_desc causing
> a crash: we are using -EFAULT which is 0xfffffff2
> as vector size, which exceeds the allocated size.
> 
> The code in question was introduced in commit
> 8dd014adfea6f173c1ef6378f7e5e7924866c923
>     vhost-net: mergeable buffers support
> 
> CVE-2014-0055
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> This is needed in -stable.

Applied and queued up for -stable, thanks Michael.
