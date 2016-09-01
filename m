From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bridge: don't increment tx_dropped in
 br_do_proxy_arp
Date: Thu, 01 Sep 2016 16:35:42 -0700 (PDT)
Message-ID: <20160901.163542.1374337978886389909.davem@davemloft.net>
References: <1472571869-3005-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kyeyoonp@codeaurora.org,
	bridge@lists.linux-foundation.org, roopa@cumulusnetworks.com
To: nikolay@cumulusnetworks.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1472571869-3005-1-git-send-email-nikolay@cumulusnetworks.com>
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

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Tue, 30 Aug 2016 17:44:29 +0200

> pskb_may_pull may fail due to various reasons (e.g. alloc failure), but the
> skb isn't changed/dropped and processing continues so we shouldn't
> increment tx_dropped.
> 
> CC: Kyeyoon Park <kyeyoonp@codeaurora.org>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> CC: Stephen Hemminger <stephen@networkplumber.org>
> CC: bridge@lists.linux-foundation.org
> Fixes: 958501163ddd ("bridge: Add support for IEEE 802.11 Proxy ARP")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thanks.
