From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: flush br's address entry in fdb
 when remove the bridge dev
Date: Mon, 18 Nov 2013 16:15:38 -0500 (EST)
Message-ID: <20131118.161538.903718006401070788.davem@davemloft.net>
References: <5289CF44.50400@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: dingtianhong@huawei.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <5289CF44.50400@huawei.com>
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

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Mon, 18 Nov 2013 16:26:44 +0800

> When the following commands are executed:
> 
> brctl addbr br0
> ifconfig br0 hw ether <addr>
> rmmod bridge
> 
> The calltrace will occur:
 ...
> The reason is that if the bridge dev's address is changed, the
> br_fdb_change_mac_address() will add new address in fdb, but when
> the bridge was removed, the address entry in the fdb did not free,
> the bridge_fdb_cache still has objects when destroy the cache, Fix
> this by flushing the bridge address entry when removing the bridge.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

This patch does not apply at all to the current 'net' tree, please
respin.

Thank you.
