From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net-next-2.6 PATCH 0/8 RFC v2] macvlan: MAC Address filtering
 support for passthru mode
Date: Mon, 24 Oct 2011 14:51:29 -0700
Message-ID: <43F901BD926A4E43B106BF17856F075501A1AE5112@orsmsx508.amr.corp.intel.com>
References: <20111024054710.GB24528@redhat.com>
 <CACAF939.37AAD%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sri@us.ibm.com" <sri@us.ibm.com>,
	"dragos.tatulea@gmail.com" <dragos.tatulea@gmail.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"dwang2@cisco.com" <dwang2@cisco.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"benve@cisco.com" <benve@cisco.com>
To: Roopa Prabhu <roprabhu@cisco.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <CACAF939.37AAD%roprabhu@cisco.com>
Content-Language: en-US
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Roopa Prabhu
> Sent: Monday, October 24, 2011 11:15 AM
> To: Michael S. Tsirkin
> Cc: netdev@vger.kernel.org; sri@us.ibm.com; dragos.tatulea@gmail.com;
> arnd@arndb.de; kvm@vger.kernel.org; davem@davemloft.net;
> mchan@broadcom.com; dwang2@cisco.com; shemminger@vyatta.com;
> eric.dumazet@gmail.com; kaber@trash.net; benve@cisco.com; Rose, Gregory V
> Subject: Re: [net-next-2.6 PATCH 0/8 RFC v2] macvlan: MAC Address
> filtering support for passthru mode
> 
> On 10/23/11 10:47 PM, "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> >> AFAIK, there is no netdev interface to install per queue hw
> >> filters for a multi queue interface. And also I dont know of any hw
> >> that provides an interface to set hw filters on a per queue basis.
> >
> > VMDq hardware would support this, no?
> >
> Am not really sure. This patch uses netdev to pass filters to hw. And I
> don't see any netdev infrastructure that would support per queue filters.
> Maybe Greg (CC'ed) or anyone else from Intel can answer this.
> Greg, michael had brought up this question during first version of these
> patches as well. Will be nice to get the VMDq requirements for propagating
> guest filters to hw clarified. Do you see any special VMDq nic requirement
> we can cover in this patch. This is for VMDq queues directly connected to
> guest nics. Thanks.

So far as I know there is no support for VMDq in the Linux kernel and while I know some folks have been working on it I can't really speak to that work or their plans.  Much would depend on the implementation.

For now it makes sense to me to get support for multiple MAC and VLAN filters per virtual function (or virtual nic) and it seems to me you're going in the right direction for this.  We'll have a look at your next set of patches and take it from there.

- Greg


