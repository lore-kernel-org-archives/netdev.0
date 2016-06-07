From: Nikolay Aleksandrov via Bridge <bridge@lists.linux-foundation.org>
Subject: Re: [PATCH net] bridge: Don't insert unnecessary local fdb
 entry on changing mac address
Date: Tue, 7 Jun 2016 13:13:23 +0200
Message-ID: <5756AC53.70406@cumulusnetworks.com>
References: <1465294457-2785-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Reply-To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
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

On 06/07/2016 12:14 PM, Toshiaki Makita wrote:
> The missing br_vlan_should_use() test caused creation of an unneeded
> local fdb entry on changing mac address of a bridge device when there is
> a vlan which is configured on a bridge port but not on the bridge
> device.
> 
> Fixes: 2594e9064a57 ("bridge: vlan: add per-vlan struct and move to rhashtables")
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---

Good catch,

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
