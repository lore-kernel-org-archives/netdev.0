From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vhost/net: fix heads usage of ubuf_info
Date: Sun, 17 Mar 2013 14:29:55 -0400 (EDT)
Message-ID: <20130317.142955.1114572401286297685.davem@davemloft.net>
References: <20130317124609.GA25967@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nab@risingtidesystems.com,
	virtualization@lists.linux-foundation.org, stable@kernel.org,
	basil.gor@gmail.com
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130317124609.GA25967@redhat.com>
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
Date: Sun, 17 Mar 2013 14:46:09 +0200

> ubuf info allocator uses guest controlled head as an index,
> so a malicious guest could put the same head entry in the ring twice,
> and we will get two callbacks on the same value.
> To fix use upend_idx which is guaranteed to be unique.
> 
> Reported-by: Rusty Russell <rusty@rustcorp.com.au>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied and queued up for -stable, thanks.

And thankfully you got the stable URL wrong, please do not CC:
networking patches to stable, just make sure I apply them and in
your post-commit text explicitly ask me to queue it up to my
-stable queue.

Thanks.
