From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Reset IPCB on forward non-local
 packets in br_handle_frame_finish()
Date: Wed, 02 Nov 2011 16:09:05 -0400 (EDT)
Message-ID: <20111102.160905.1169586186411464818.davem@davemloft.net>
References: <4EB19549.4010601@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org, devel@openvz.org,
	herbert@gondor.hengli.com.au
To: vvs@parallels.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <4EB19549.4010601@parallels.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Vasily Averin <vvs@parallels.com>
Date: Wed, 02 Nov 2011 23:08:57 +0400

> if dst is not local br_handle_frame_finish() does not clone original skb and
> forgets to reset IPCB before return to IP stack. it can lead to stack corruption
> in icmp_send()
> 
> Signed-off-by: Vasily Averin <vvs@sw.ru>

Nothing is worse than posting a patch that doesn't even compile.

And I really mean _nothing_.
