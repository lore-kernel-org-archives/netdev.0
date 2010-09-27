From: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re:
Date: Mon, 27 Sep 2010 13:14:11 -0700
Message-ID: <OF056C7E7C.A9A5EFC7-ON882577AB.006E6B89-882577AB.006F2C1E@us.ibm.com>
References: <20100927200500.GB25879@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100927200500.GB25879-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org> wrote on 09/27/2010 
01:05:00 PM:

> On Mon, Sep 27, 2010 at 12:32:45PM -0700, David Stevens wrote:
> 
> > You can, of course, add a querier (or configure it, assuming an
> > attached switch supports it) and set the query interval and
> > robustness count as appropriate for that network.
> 
> Presumably the IPoIB multicast router should already be the querier..
> How does this help handling joins to new groups?

        Because a querier can set the robustness value and
query interval to anything you want. In the original report,
he's not running a querier. The fact that it's a new group
doesn't matter -- these are per-interface.

                                                        +-DLS

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
