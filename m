From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net bridge: add null pointer check, fix panic
Date: Wed, 19 Jun 2013 21:55:29 -0700
Message-ID: <1371704129.3252.356.camel@edumazet-glaptop>
References: <51C2710D.2060405@gmail.com> <51C2721B.9050603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: xiaoming gao <gxm.linux.kernel@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <51C2721B.9050603@gmail.com>
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

On Thu, 2013-06-20 at 11:08 +0800, xiaoming gao wrote:
> From: newtongao <newtongao@tencent.com>
> Date: Wed, 19 Jun 2013 14:58:33 +0800
> Subject: [PATCH] net bridge: add null pointer check,fix panic
> 
> in kernel 3.0, br_port_get_rcu() may return NULL when network interface be deleting from bridge,
> but in function br_handle_frame and br_handle_local_finish, the pointer didn't be checked before using,
> so all br_port_get_rcu callers must do null check,or there occurs the null pointer panic.
> 
> kernel 3.4 also has this bug,i have verified.
> mainline kernel still did not  check br_port_get_rcu()'s NULL pointer, but i have not tested it yet.

Please check current version before sending a patch.

This was most probably fixed in commit 00cfec37484761a44
("net: add a synchronize_net() in netdev_rx_handler_unregister()")

Thanks
