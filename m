From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH v4 18/20] net/xen-netback: Make it running on
 64KB page granularity
Date: Tue, 8 Sep 2015 12:09:33 +0100
Message-ID: <20150908110933.GB12714@zion.uk.xensource.com>
References: <1441640038-23615-1-git-send-email-julien.grall@citrix.com>
 <1441640038-23615-19-git-send-email-julien.grall@citrix.com>
 <20150907165727.GT6436@zion.uk.xensource.com> <55EEC173.6020606@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Julien Grall <julien.grall@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55EEC173.6020606@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 08, 2015 at 12:07:31PM +0100, Julien Grall wrote:
> Hi Wei,
> 
> On 07/09/15 17:57, Wei Liu wrote:
> > You might need to rebase you patch. A patch to netback went it recently.
> 
> Do you mean 210c34dcd8d912dcc740f1f17625a7293af5cb56 "xen-netback: add
> support for multicast control"?
> 

Yes, that one.

> If so I didn't see any specific issue while rebasing on the latest
> linus' master.
> 

Good.

> > On Mon, Sep 07, 2015 at 04:33:56PM +0100, Julien Grall wrote:
> >> The PV network protocol is using 4KB page granularity. The goal of this
> >> patch is to allow a Linux using 64KB page granularity working as a
> >> network backend on a non-modified Xen.
> >>
> >> It's only necessary to adapt the ring size and break skb data in small
> >> chunk of 4KB. The rest of the code is relying on the grant table code.
> >>
> >> Signed-off-by: Julien Grall <julien.grall@citrix.com>
> >>
> > 
> > Reviewed-by: Wei Liu <wei.liu2@citrix.com>
> 
> Thank you!
> 
> Regards,
> 
> -- 
> Julien Grall
