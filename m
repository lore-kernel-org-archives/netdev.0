From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [net-next-2.6 PATCH 0/8 RFC v2] macvlan: MAC Address filtering
 support for passthru mode
Date: Tue, 25 Oct 2011 08:59:40 -0700
Message-ID: <43F901BD926A4E43B106BF17856F075501A1AE542A@orsmsx508.amr.corp.intel.com>
References: <20111024054710.GB24528@redhat.com>
 <CACAF939.37AAD%roprabhu@cisco.com> <20111025154617.GB22553@redhat.com>
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
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Roopa Prabhu <roprabhu@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:53763 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756624Ab1JYP7n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 11:59:43 -0400
In-Reply-To: <20111025154617.GB22553@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Michael S. Tsirkin [mailto:mst@redhat.com]
> Sent: Tuesday, October 25, 2011 8:46 AM
> To: Roopa Prabhu
> Cc: netdev@vger.kernel.org; sri@us.ibm.com; dragos.tatulea@gmail.com;
> arnd@arndb.de; kvm@vger.kernel.org; davem@davemloft.net;
> mchan@broadcom.com; dwang2@cisco.com; shemminger@vyatta.com;
> eric.dumazet@gmail.com; kaber@trash.net; benve@cisco.com; Rose, Gregory V
> Subject: Re: [net-next-2.6 PATCH 0/8 RFC v2] macvlan: MAC Address
> filtering support for passthru mode
> 
> On Mon, Oct 24, 2011 at 11:15:05AM -0700, Roopa Prabhu wrote:
> > >> ... And also I dont know of any hw
> > >> that provides an interface to set hw filters on a per queue basis.
> > >
> > > VMDq hardware would support this, no?
> > >
> > Am not really sure. This patch uses netdev to pass filters to hw. And I
> > don't see any netdev infrastructure that would support per queue
> filters.
> 
> Sure. I was only saying that as far as I understand,
> VMDq hardware does support this functionality.
> Right, Greg?

In the case of Intel HW yes.  I'll refrain from speaking for other HW vendors although I'm guessing it would be true in their cases also.  YMMV, caveat emptor, etc. etc.

- Greg

> 
> --
> MST
