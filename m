From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 1/8] netback: don't bind kthread to cpu
Date: Tue, 5 Mar 2013 14:04:28 +0000
Message-ID: <1362492268.4748.25.camel@zion.uk.xensource.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
	 <1360944010-15336-2-git-send-email-wei.liu2@citrix.com>
	 <20130304205154.GB16762@phenom.dumpdata.com>
	 <1362490210.4748.23.camel@zion.uk.xensource.com>
	 <20130305135649.GA2589@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:32599 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755014Ab3CEOE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Mar 2013 09:04:29 -0500
In-Reply-To: <20130305135649.GA2589@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-05 at 13:56 +0000, Konrad Rzeszutek Wilk wrote:
> On Tue, Mar 05, 2013 at 01:30:10PM +0000, Wei Liu wrote:
> > On Mon, 2013-03-04 at 20:51 +0000, Konrad Rzeszutek Wilk wrote:
> > > On Fri, Feb 15, 2013 at 04:00:02PM +0000, Wei Liu wrote:
> > > > The initialization process makes an assumption that the online cpus are
> > > > numbered from 0 to xen_netbk_group_nr-1,  which is not always true.
> > > 
> > > And xen_netbk_group_nr is num_online_cpus()?
> > > 
> > 
> > Yes.
> > 
> > > So under what conditions does this change? Is this when the CPU hotplug
> > > is involved and the CPUs go offline? In which case should there be a
> > 
> > Yes, the hotplug path.
> > 
> > > CPU hotplug notifier to re-bind the workers are appropiate?
> 
> ?
> Can't that option be explored?

Thinking about it. Should be doable.


Wei.
