From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/2] virtio: support unlocked queue poll
Date: Wed, 10 Jul 2013 12:39:58 +0930
Message-ID: <87k3kzcdq1.fsf@rustcorp.com.au>
References: <1373274069-4301-1-git-send-email-mst@redhat.com>
	<1373274069-4301-2-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1373274069-4301-2-git-send-email-mst@redhat.com>
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

"Michael S. Tsirkin" <mst@redhat.com> writes:
> This adds a way to check ring empty state after enable_cb outside any
> locks. Will be used by virtio_net.
>
> Note: there's room for more optimization: caller is likely to have a
> memory barrier already, which means we might be able to get rid of a
> barrier here.  Deferring this optimization until we do some
> benchmarking.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks,
Rusty.
