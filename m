From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: Don't insert unnecessary local fdb
 entry on changing mac address
Date: Wed, 08 Jun 2016 00:33:11 -0700 (PDT)
Message-ID: <20160608.003311.700392281898371509.davem@davemloft.net>
References: <1465294457-2785-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	nikolay@cumulusnetworks.com
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1465294457-2785-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
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

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Tue,  7 Jun 2016 19:14:17 +0900

> The missing br_vlan_should_use() test caused creation of an unneeded
> local fdb entry on changing mac address of a bridge device when there is
> a vlan which is configured on a bridge port but not on the bridge
> device.
> 
> Fixes: 2594e9064a57 ("bridge: vlan: add per-vlan struct and move to rhashtables")
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Applied and queued up for -stable, thanks.
