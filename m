From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v1 03/12] IB/ipoib: Return IPoIB devices matching connection
 parameters
Date: Thu, 9 Jul 2015 12:57:31 +0300
Message-ID: <559E458B.4020709@mellanox.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
 <1434976961-27424-4-git-send-email-haggaie@mellanox.com>
 <20150708234111.GC16812@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150708234111.GC16812-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/07/2015 02:41, Jason Gunthorpe wrote:
> On Mon, Jun 22, 2015 at 03:42:32PM +0300, Haggai Eran wrote:
>> +		if (net_dev) {
>> +			ipoib_warn(priv, "matching net_dev found: %s\n",
>> +				   net_dev->name);
> 
> Is that a debug print?

Yes, I'm afraid it slipped in somehow. I'll remove it.

> 
>> +	default:
>> +		dev_warn(&dev->dev, "duplicate IP address detected\n");
>> +		/* Fall through */
> 
> Surely that needs some kind of rate limit?

I'll use dev_warn_ratelimited().

Thanks,
Haggai
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
