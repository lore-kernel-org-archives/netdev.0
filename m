From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] tun: Interface to query tun/tap features.
Date: Thu, 03 Jul 2008 03:45:49 -0700 (PDT)
Message-ID: <20080703.034549.26677937.davem@davemloft.net>
References: <200807031132.12810.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maxk@qualcomm.com,
        virtualization@lists.linux-foundation.org
To: rusty@rustcorp.com.au
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <200807031132.12810.rusty@rustcorp.com.au>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Thu, 3 Jul 2008 11:32:12 +1000

> The problem with introducing checksum offload and gso to tun is they
> need to set dev->features to enable GSO and/or checksumming, which is
> supposed to be done before register_netdevice(), ie. as part of
> TUNSETIFF.
 ...
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Applied to net-next-2.6, thanks!
