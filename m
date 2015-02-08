From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: add missing bridge port check
 for offloads
Date: Sat, 07 Feb 2015 22:50:12 -0800 (PST)
Message-ID: <20150207.225012.779384501646874610.davem@davemloft.net>
References: <1423203885-45657-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	dan.carpenter@oracle.com
To: roopa@cumulusnetworks.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1423203885-45657-1-git-send-email-roopa@cumulusnetworks.com>
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

From: roopa@cumulusnetworks.com
Date: Thu,  5 Feb 2015 22:24:45 -0800

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch fixes a missing bridge port check caught by smatch.
> 
> setlink/dellink of attributes like vlans can come for a bridge device
> and there is no need to offload those today. So, this patch adds a bridge
> port check. (In these cases however, the BRIDGE_SELF flags will always be set
> and we may not hit a problem with the current code).
> 
> smatch complaint:
> 
> The patch 68e331c785b8: "bridge: offload bridge port attributes to
> switch asic if feature flag set" from Jan 29, 2015, leads to the
> following Smatch complaint:
> 
> net/bridge/br_netlink.c:552 br_setlink()
> 	 error: we previously assumed 'p' could be null (see line 518)
> 
> net/bridge/br_netlink.c
>    517
>    518		if (p && protinfo) {
>                     ^
> Check for NULL.
> 
> Reported-By: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied, thanks.
