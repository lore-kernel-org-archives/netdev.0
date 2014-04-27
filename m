From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bridge: Handle IFLA_ADDRESS correctly
 when creating bridge device
Date: Sun, 27 Apr 2014 19:54:12 -0400 (EDT)
Message-ID: <20140427.195412.646574309300796885.davem@davemloft.net>
References: <20140424113827.6d27ec5b@nehalam.linuxnetplumber.net>
	<1398412451.3920.3.camel@ubuntu-vm-makita>
	<1398412878.3920.7.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org, teg@jklm.no,
	bridge@lists.linux-foundation.org, cr@saltstack.com
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1398412878.3920.7.camel@ubuntu-vm-makita>
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
Date: Fri, 25 Apr 2014 17:01:18 +0900

> When bridge device is created with IFLA_ADDRESS, we are not calling
> br_stp_change_bridge_id(), which leads to incorrect local fdb
> management and bridge id calculation, and prevents us from receiving
> frames on the bridge device.
> 
> Reported-by: Tom Gundersen <teg@jklm.no>
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Applied and queued up for -stable.
