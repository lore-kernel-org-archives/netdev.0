From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: only provide proxy ARP when
 CONFIG_INET is enabled
Date: Wed, 14 Jan 2015 15:08:22 -0500 (EST)
Message-ID: <20150114.150822.992076699268375825.davem@davemloft.net>
References: <56868207.rHBDZL3pbk@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kyeyoonp@codeaurora.org,
	bridge@lists.linux-foundation.org
To: arnd@arndb.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <56868207.rHBDZL3pbk@wuerfel>
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

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 13 Jan 2015 15:10:27 +0100

> When IPV4 support is disabled, we cannot call arp_send from
> the bridge code, which would result in a kernel link error:
> 
> net/built-in.o: In function `br_handle_frame_finish':
> :(.text+0x59914): undefined reference to `arp_send'
> :(.text+0x59a50): undefined reference to `arp_tbl'
> 
> This makes the newly added proxy ARP support in the bridge
> code depend on the CONFIG_INET symbol and lets the compiler
> optimize the code out to avoid the link error.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 958501163ddd ("bridge: Add support for IEEE 802.11 Proxy ARP")

Applied, thanks Arnd.
