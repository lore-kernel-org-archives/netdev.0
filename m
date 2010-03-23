From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH] ipoib: remove addrlen check for mc
 addresses
Date: Mon, 22 Mar 2010 18:34:50 -0700 (PDT)
Message-ID: <20100322.183450.135981771.davem@davemloft.net>
References: <20100322132138.GC2780@psychotron.lab.eng.brq.redhat.com>
	<20100322165916.GE29129@obsidianresearch.com>
	<20100322172613.GA2884@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	monis-smomgflXvOZWk0Htik3J/w@public.gmane.org
To: jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100322172613.GA2884-YzwxZg+R7et1/kRsl7OVgNvLeJWuRmrY@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Mon, 22 Mar 2010 18:26:14 +0100

> Mon, Mar 22, 2010 at 05:59:16PM CET, jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org wrote:
>>On Mon, Mar 22, 2010 at 02:21:39PM +0100, Jiri Pirko wrote:
>>> Finally this bit can be removed. Currently, after the bonding driver is
>>> changed/fixed (32a806c194ea112cfab00f558482dd97bee5e44e net-next-2.6),
>>> that's not possible for an addr with different length than dev->addr_len
>>> to be present in list. Removing this check as in new mc_list there will be
>>> no addrlen in the record.
>>
>>Maybe just make this check a WARN_ON?
> 
> As I said, addrlen will no longer be in record (because it would have no
> meaning since length ot the addr is always dev->addr_len)
> 
>>Can userspace create a mc_list
>>entry with the wrong size via netlink?
> 
> Nope - this is not possible. dev->addr_len is used.

I've applied your patch, thanks Jiri.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
