From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net/core: use net_device dev_id to indicate port number
Date: Wed, 26 May 2010 08:23:06 -0700
Message-ID: <20100526082306.25959fb6@nehalam>
References: <20100526095200.GA7370@mtldesk030.lab.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100526095200.GA7370-8YAHvHwT2UEvbXDkjdHOrw/a8Rv0c6iv@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 26 May 2010 12:52:00 +0300
Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org> wrote:

> Today, there are no means to know which port of a hardware device a netdev
> interface uses. struct net_device conatins a field, dev_id, that can be used
> for that. This patch adds a new macro, SET_NETDEV_DEV_ID(), to provide a
> standard way to set the value of this field.
> Also also make use of this feature in the mlx4_en driver to set the port
> number; port numbers are zero based.

Why is a macro wrapper needed?

-- 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
