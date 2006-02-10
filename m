From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/3] bridge: netfilter handle RCU during removal
Date: Thu, 09 Feb 2006 17:09:47 -0800 (PST)
Message-ID: <20060209.170947.00691910.davem@davemloft.net>
References: <20060206222732.661214000@dxpl.pdx.osdl.net>
	<20060206222853.844546000@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: shemminger@osdl.org
In-Reply-To: <20060206222853.844546000@dxpl.pdx.osdl.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 06 Feb 2006 14:27:34 -0800

> Bridge netfilter code needs to handle the case where device is
> removed from bridge while packet in process. In these cases the
> bridge_parent can be come null while processing.
> 
> This should fix: http://bugzilla.kernel.org/show_bug.cgi?id=5803
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied to net-2.6, thanks a lot.
