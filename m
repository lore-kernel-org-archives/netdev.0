From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-next-2.6 PATCH 0/8 RFC v2] macvlan: MAC Address filtering
 support for passthru mode
Date: Thu, 17 Nov 2011 23:43:41 +0000
Message-ID: <1321573421.2749.38.camel@bwh-desktop>
References: <20111024054710.GB24528@redhat.com>
	 <CACAF939.37AAD%roprabhu@cisco.com> <20111025154617.GB22553@redhat.com>
	 <43F901BD926A4E43B106BF17856F075501A1AE542A@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roprabhu@cisco.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
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
To: "Michael S. Tsirkin" <mst@redhat.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <43F901BD926A4E43B106BF17856F075501A1AE542A@orsmsx508.amr.corp.intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-10-25 at 08:59 -0700, Rose, Gregory V wrote:
> > -----Original Message-----
> > From: Michael S. Tsirkin [mailto:mst@redhat.com]
> > Sent: Tuesday, October 25, 2011 8:46 AM
> > To: Roopa Prabhu
> > Cc: netdev@vger.kernel.org; sri@us.ibm.com; dragos.tatulea@gmail.com;
> > arnd@arndb.de; kvm@vger.kernel.org; davem@davemloft.net;
> > mchan@broadcom.com; dwang2@cisco.com; shemminger@vyatta.com;
> > eric.dumazet@gmail.com; kaber@trash.net; benve@cisco.com; Rose, Gregory V
> > Subject: Re: [net-next-2.6 PATCH 0/8 RFC v2] macvlan: MAC Address
> > filtering support for passthru mode
> > 
> > On Mon, Oct 24, 2011 at 11:15:05AM -0700, Roopa Prabhu wrote:
> > > >> ... And also I dont know of any hw
> > > >> that provides an interface to set hw filters on a per queue basis.
> > > >
> > > > VMDq hardware would support this, no?
> > > >
> > > Am not really sure. This patch uses netdev to pass filters to hw. And I
> > > don't see any netdev infrastructure that would support per queue
> > filters.
> > 
> > Sure. I was only saying that as far as I understand,
> > VMDq hardware does support this functionality.
> > Right, Greg?
> 
> In the case of Intel HW yes.  I'll refrain from speaking for other HW
> vendors although I'm guessing it would be true in their cases also.
> YMMV, caveat emptor, etc. etc.

Current Solarflare hardware supports:
- RX MAC address filters for queue selection (steering), which can be
  combined with RSS (flow hashing)
- TX MAC address filters to prevent spoofing
Multiple filters can be associated with a single queue.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

