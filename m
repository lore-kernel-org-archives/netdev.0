From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net-next-2.6 PATCH 0/6 RFC v3] macvlan: MAC Address filtering
 support for passthru mode
Date: Mon, 31 Oct 2011 10:39:49 -0700
Message-ID: <43F901BD926A4E43B106BF17856F075501A1BD52F6@orsmsx508.amr.corp.intel.com>
References: <43F901BD926A4E43B106BF17856F075501A1BD5241@orsmsx508.amr.corp.intel.com>
 <CAD42458.3856A%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "sri@us.ibm.com" <sri@us.ibm.com>,
	"dragos.tatulea@gmail.com" <dragos.tatulea@gmail.com>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, "mst@redhat.com" <mst@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"dwang2@cisco.com" <dwang2@cisco.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"benve@cisco.com" <benve@cisco.com>
To: Roopa Prabhu <roprabhu@cisco.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <CAD42458.3856A%roprabhu@cisco.com>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Roopa Prabhu [mailto:roprabhu@cisco.com]
> Sent: Monday, October 31, 2011 10:09 AM
> To: Rose, Gregory V; netdev@vger.kernel.org
> Cc: sri@us.ibm.com; dragos.tatulea@gmail.com; kvm@vger.kernel.org;
> arnd@arndb.de; mst@redhat.com; davem@davemloft.net; mchan@broadcom.com;
> dwang2@cisco.com; shemminger@vyatta.com; eric.dumazet@gmail.com;
> kaber@trash.net; benve@cisco.com
> Subject: Re: [net-next-2.6 PATCH 0/6 RFC v3] macvlan: MAC Address
> filtering support for passthru mode
> 
> 
> 
> 
> On 10/31/11 9:38 AM, "Rose, Gregory V" <gregory.v.rose@intel.com> wrote:
> 
> >> -----Original Message-----
> >> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org]
> >> On Behalf Of Roopa Prabhu
> >> Sent: Friday, October 28, 2011 7:34 PM
> >> To: netdev@vger.kernel.org
> >> Cc: sri@us.ibm.com; dragos.tatulea@gmail.com; kvm@vger.kernel.org;
> >> arnd@arndb.de; mst@redhat.com; davem@davemloft.net; Rose, Gregory V;
> >> mchan@broadcom.com; dwang2@cisco.com; shemminger@vyatta.com;
> >> eric.dumazet@gmail.com; kaber@trash.net; benve@cisco.com
> >> Subject: [net-next-2.6 PATCH 0/6 RFC v3] macvlan: MAC Address filtering
> >> support for passthru mode
> >>
> >> v2 -> v3
> >> - Moved set and get filter ops from rtnl_link_ops to netdev_ops
> >> - Support for SRIOV VFs.
> >> [Note: The get filters msg might get too big for SRIOV vfs.
> >>         But this patch follows existing sriov vf get code and
> >> accomodate filters for all VF's in a PF.
> >>         And for the SRIOV case I have only tested the fact that the VF
> >> arguments are getting delivered to rtnetlink correctly. The rest of
> >> the code follows existing sriov vf handling code so it should work
> >> just fine]
> >> - Fixed all op and netlink attribute names to start with IFLA_RX_FILTER
> >> - Changed macvlan filter ops to call corresponding lowerdev op if
> lowerdev
> >>   supports it for passthru mode. Else it falls back on macvlan handling
> >> the
> >>   filters locally as in v1 and v2
> >>
> >> v1 -> v2
> >> - Instead of TUNSETTXFILTER introduced rtnetlink interface for the same
> >>
> >
> > [snip...]
> >
> >>
> >> This patch series implements the following
> >> 01/6 rtnetlink: Netlink interface for setting MAC and VLAN filters
> >> 02/6 netdev: Add netdev_ops to set and get MAC/VLAN rx filters
> >> 03/6 rtnetlink: Add support to set MAC/VLAN filters
> >> 04/6 rtnetlink: Add support to get MAC/VLAN filters
> >> 05/6 macvlan: Add support to set MAC/VLAN filter netdev ops
> >> 06/6 macvlan: Add support to get MAC/VLAN filter netdev ops
> >>
> >> Please comment. Thanks.
> >
> > After some preliminary review this looks pretty good to me in so far as
> adding
> > the necessary hooks to do what I need to do.  I appreciate your effort
> on
> > this.
> >
> > I'm sort of a hands-on type of person so I need to apply this patch to a
> > private git tree and then take it for a test drive (so to speak).  If I have
> > further comments I'll get back to you.
> >
> Sounds good.
> 
> > Did you have any plans for modifying any user space tools such as 'ip' to use
> > this interface?
> >
> 
> Yes, I have an iproute2 sample patch for setting and displaying the filters
> which I have been using to test this interface. I can send the patch to you
> after some cleanup if you think it will be useful for you to try out this
> interface.
> 
> Thanks Greg.

Yes, please do.

Thanks,

- Greg

