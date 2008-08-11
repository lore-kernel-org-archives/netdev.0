From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Mon, 11 Aug 2008 16:45:03 -0700
Message-ID: <200808111645.04677.divy@chelsio.com>
References: <adavdy9zc2k.fsf@cisco.com> <20080811.140918.213422266.davem@davemloft.net> <48A0C927.8020501@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, rdreier@cisco.com,
	jgarzik@pobox.com, "Karen Xie" <kxie@chelsio.com>,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, "Dimitrios Michailidis" <dm@chelsio.com>,
	"Casey Leedom" <leedom@chelsio.com>, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Steve Wise" <swise@opengridcomputing.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <48A0C927.8020501@opengridcomputing.com>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 11 August 2008 04:20:07 pm Steve Wise wrote:
> David Miller wrote:
> > From: Roland Dreier <rdreier@cisco.com>
> > Date: Mon, 11 Aug 2008 09:09:02 -0700
> >
> >>  > We turn it off.  If I want to shape or filter one of these iSCSI
> >>  > connections can we turn it off?
> >>
> >> That seems like a reasonable idea to me -- the standard thing to do when
> >> a NIC offload conflicts with something else is to turn off the offload
> >> and fall back to software.
> >
> > But as Herbert says, we can make LRO such that turning it off
> > isn't necessary.
> >
> > Can we shape the iSCSI offload traffic without turning it off?
>
> With Chelsio's product you can do this.  Maybe Divy can provide details?

The T3 adapter is capable of performing rate control and pacing based on RTT 
on a per-connection basis.

Cheers,
Divy
