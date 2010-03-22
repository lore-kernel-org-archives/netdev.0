From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [net-next-2.6 PATCH] ipoib: remove addrlen check for mc
	addresses
Date: Mon, 22 Mar 2010 10:59:16 -0600
Message-ID: <20100322165916.GE29129@obsidianresearch.com>
References: <20100322132138.GC2780@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, monis-smomgflXvOZWk0Htik3J/w@public.gmane.org
To: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100322132138.GC2780-YzwxZg+R7evMbnheQZGK0N5OCZ2W11yPFxja6HXR22MAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 22, 2010 at 02:21:39PM +0100, Jiri Pirko wrote:
> Finally this bit can be removed. Currently, after the bonding driver is
> changed/fixed (32a806c194ea112cfab00f558482dd97bee5e44e net-next-2.6),
> that's not possible for an addr with different length than dev->addr_len
> to be present in list. Removing this check as in new mc_list there will be
> no addrlen in the record.

Maybe just make this check a WARN_ON? Can userspace create a mc_list
entry with the wrong size via netlink?

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
