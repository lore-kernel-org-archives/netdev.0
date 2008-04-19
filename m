From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/5] tun: vringfd xmit support.
Date: Fri, 18 Apr 2008 18:54:43 -0700
Message-ID: <20080418185443.7aa07ccf.akpm@linux-foundation.org>
References: <200804181433.48488.rusty@rustcorp.com.au>
	<200804181443.24812.rusty@rustcorp.com.au>
	<20080418043120.ff78eab5.akpm@linux-foundation.org>
	<200804190115.15983.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Max Krasnyansky <maxk@qualcomm.com>,
        virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <200804190115.15983.rusty@rustcorp.com.au>
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

On Sat, 19 Apr 2008 01:15:15 +1000 Rusty Russell <rusty@rustcorp.com.au> wrote:

> It's not clear to me why this is in swap.c, but it exists
> even without CONFIG_SWAP, so that's OK.

We should have done mv mm/swap.c mm/mmlib.c years ago.
