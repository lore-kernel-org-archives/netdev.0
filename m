From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] net: Move destructor from neigh->ops
	to neigh_params
Date: Mon, 06 Mar 2006 22:11:45 -0800 (PST)
Message-ID: <20060306.221145.77110160.davem@davemloft.net>
References: <adazmlmmy7v.fsf@cisco.com> <20060306211630.0df79464.akpm@osdl.org>
	<ada7j7624h9.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: rdreier@cisco.com
In-Reply-To: <ada7j7624h9.fsf@cisco.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 06 Mar 2006 21:44:50 -0800

>     Roland> struct neigh_ops currently has a destructor field, which
>     Roland> no in-kernel drivers outside of infiniband use.
> 
>     Andrew> net/atm/clip.c begs to disagree.
> 
> err... my fault for trusting the patch changelog and not
> double-checking.  I think the fix is as simple as, although, given my
> lack of ATM gear, this is untested:

Looks good to me, applied.
