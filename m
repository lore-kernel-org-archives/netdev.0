From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: linux-next: build failure after merge of the origin tree
Date: Mon, 7 Nov 2011 08:46:35 -0800
Message-ID: <43F901BD926A4E43B106BF17856F075501A1CCA399@orsmsx508.amr.corp.intel.com>
References: <20111107101202.96fcb76d580e5265bd99aeee@canb.auug.org.au>
 <20111106.205259.1237400984015921904.davem@davemloft.net>
 <20111107134706.3e7fc633f913b5e155153127@canb.auug.org.au>
 <20111106.223619.1348742215191441592.davem@davemloft.net>
 <EAE7BD3E-8965-47A4-B3CA-01686E2602C2@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <EAE7BD3E-8965-47A4-B3CA-01686E2602C2@intel.com>
Content-Language: en-US
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Kirsher, Jeffrey T
> Sent: Sunday, November 06, 2011 9:30 PM
> To: David Miller
> Cc: sfr@canb.auug.org.au; torvalds@linux-foundation.org; linux-
> next@vger.kernel.org; linux-kernel@vger.kernel.org; Rose, Gregory V;
> netdev@vger.kernel.org
> Subject: Re: linux-next: build failure after merge of the origin tree
> 
> 
> 
> Cheers,
> Jeff
> 
> On Nov 6, 2011, at 19:38, "David Miller" <davem@davemloft.net> wrote:
> 
> > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > Date: Mon, 7 Nov 2011 13:47:06 +1100
> >
> >>> If you just revert the commit in origin from -next, then you will get
> >>> conflicts with you pull the net.git tree in.
> >>
> >> I got no conflicts when I merged in the net tree and can see no fix for
> >> this problem in the net tree.  My current head of the net tree is
> 1a6422f
> >> "etherh: Add MAINTAINERS entry for etherh".
> >
> > Ok, Jeff please take a look at this and send me a fix soon.
> >
> > Thanks.
> 
> Ok Dave, at this point, I am puttying together a patch to revert this fix
> since it appears that more trouble comes with this fix.  I will take a
> look at it quickly before sending out a patch to fix the issue.

My bad...  I fixed a compiler warning that occurred with CONFIG_PCI_IOV turned on and didn't realize that my patch would cause an error when turning it back off.

I'll have it fixed ASAP.

- Greg
