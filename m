From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 1/3] net: allow > 0 order atomic page alloc in
	skb_page_frag_refill
Date: Mon, 23 Dec 2013 15:35:26 +0200
Message-ID: <20131223133526.GE18168@redhat.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>
	<20131219.145815.1332595160898710763.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mwdalton@google.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20131219.145815.1332595160898710763.davem@davemloft.net>
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

On Thu, Dec 19, 2013 at 02:58:15PM -0500, David Miller wrote:
> 
> Can I get some reviews of this series from virtio folks?
> 
> Thanks.

I think it's a good idea, certainly the best we can do
short term.
Would like a couple of comments addressed before it's applied.

Longer term one approach to consider is to make device
look aheads in the VQ until it finds a large
enough buffer.

-- 
MST
