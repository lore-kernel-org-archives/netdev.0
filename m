From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: netlink: fix
 slave_changelink/br_setport race conditions
Date: Sun, 26 Jul 2015 16:28:27 -0700 (PDT)
Message-ID: <20150726.162827.595252911514712549.davem@davemloft.net>
References: <1437563020-23506-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org, jiri@resnulli.us,
	nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1437563020-23506-1-git-send-email-razor@blackwall.org>
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

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Wed, 22 Jul 2015 13:03:40 +0200

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Since slave_changelink support was added there have been a few race
> conditions when using br_setport() since some of the port functions it
> uses require the bridge lock. It is very easy to trigger a lockup due to
> some internal spin_lock() usage without bh disabled, also it's possible to
> get the bridge into an inconsistent state.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Fixes: 3ac636b8591c ("bridge: implement rtnl_link_ops->slave_changelink")

Applied and queued up for -stable, thanks.
