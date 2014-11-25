From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] bonding: move ipoib_header_ops to vmlinux
Date: Tue, 25 Nov 2014 09:19:10 +0200
Message-ID: <54742D6E.9030605@mellanox.com>
References: <1416893768-21369-1-git-send-email-wen.gang.wang@oracle.com>
 <20141125.010741.450666241983239119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wen.gang.wang-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141125.010741.450666241983239119.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/25/2014 8:07 AM, David Miller wrote:
> IPOIB should not work over bonding as it requires that the device
> use ARPHRD_ETHER.

Hi Dave,

IPoIB devices can be enslaved to both bonding and teaming in their HA mode,
the bond device type becomes ARPHRD_INFINIBAND when this happens.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
