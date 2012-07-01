From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] netfilter: use kfree_skb() not kfree()
Date: Sat, 30 Jun 2012 17:27:08 -0700 (PDT)
Message-ID: <20120630.172708.1209859499944103648.davem@davemloft.net>
References: <20120630114853.GA22767@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	kernel-janitors@vger.kernel.org, bart.de.schuymer@pandora.be,
	netfilter-devel@vger.kernel.org, shemminger@vyatta.com, pablo@netfilter.org
To: dan.carpenter@oracle.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20120630114853.GA22767@elgon.mountain>
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

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sat, 30 Jun 2012 14:48:53 +0300

> This was should be a kfree_skb() here to free the sk_buff pointer.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

My bad, applied, thanks Dan.
