From: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re:
Date: Mon, 27 Sep 2010 14:50:01 -0700
Message-ID: <OF980F8B87.D755A28E-ON882577AB.00779881-882577AB.0077F27A@us.ibm.com>
References: <20100927200500.GB25879@obsidianresearch.com> <OF056C7E7C.A9A5EFC7-ON882577AB.006E6B89-882577AB.006F2C1E@us.ibm.com> <alpine.DEB.2.00.1009271521510.14117@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1009271521510.14117-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org> wrote on 09/27/2010 01:23:00 PM:

> From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
> To: David Stevens/Beaverton/IBM@IBMUS
> Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>, linux-
> rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-
> owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>
> Date: 09/27/2010 01:23 PM
> Subject: Re:
> 
> On Mon, 27 Sep 2010, David Stevens wrote:
> 
> >         Because a querier can set the robustness value and
> > query interval to anything you want. In the original report,
> > he's not running a querier. The fact that it's a new group
> > doesn't matter -- these are per-interface.
> 
> The per interface settings are used to force an IGMP version overriding
> any information by the queriers.

        No. I'm not talking about the force_igmp_tunable here, I'm talking
about the per-interface robustness and interval settings which come from
the querier (whatever version you are using).

> You would not want to enable that because
> it disables support for other IGMP versions. Without the override
> different version of IGMP can be handled per MC group.

        No. IGMPv3 includes backward compatibility for both IGMPv2 and
IGMPv1. If queries for an earlier version are present, that is the
IGMP version all use, and the features of the later version are not
available to anyone.

                                                                +-DLS


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
