From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] bridge: Fix inabillity to retrieve
 vlan tags when tx offload is disabled
Date: Fri, 28 Mar 2014 16:33:36 -0400 (EDT)
Message-ID: <20140328.163336.1242033159764820959.davem@davemloft.net>
References: <1395924416-12325-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, vyasevic@redhat.com,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1395924416-12325-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
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
Date: Thu, 27 Mar 2014 21:46:55 +0900

> Bridge vlan code (br_vlan_get_tag()) assumes that all frames have vlan_tci
> if they are tagged, but if vlan tx offload is manually disabled on bridge
> device and frames are sent from vlan device on the bridge device, the tags
> are embedded in skb->data and they break this assumption.
> Extract embedded vlan tags and move them to vlan_tci at ingress.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Applied.
