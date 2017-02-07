From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] net: bridge: remove redundant check
 to see if err is set
Date: Tue, 07 Feb 2017 14:05:01 -0500 (EST)
Message-ID: <20170207.140501.318284472850132434.davem@davemloft.net>
References: <20170207105638.17918-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170207105638.17918-1-colin.king@canonical.com>
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

From: Colin King <colin.king@canonical.com>
Date: Tue,  7 Feb 2017 10:56:38 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> The error check on err is redundant as it is being checked
> previously each time it has been updated.  Remove this redundant
> check.
> 
> Detected with CoverityScan, CID#140030("Logically dead code")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
