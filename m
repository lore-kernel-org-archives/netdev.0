From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [RFC PATCH V2] New Xen netback implementation
Date: Mon, 30 Jan 2012 15:49:57 +0000
Message-ID: <1327938597.26983.246.camel@zakaz.uk.xensource.com>
References: <1326808024-3744-1-git-send-email-wei.liu2@citrix.com>
	 <20120127192214.GA14437@phenom.dumpdata.com>
	 <1327936037.26983.241.camel@zakaz.uk.xensource.com>
	 <20120130152109.GA17923@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:15633 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753196Ab2A3Pt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 10:49:59 -0500
In-Reply-To: <20120130152109.GA17923@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-01-30 at 15:21 +0000, Konrad Rzeszutek Wilk wrote:
> On Mon, Jan 30, 2012 at 03:07:16PM +0000, Ian Campbell wrote:
> > On Fri, 2012-01-27 at 19:22 +0000, Konrad Rzeszutek Wilk wrote:
> > > 
> > >  - This patch set solves the CPU banding problem I've seen with the
> > >    older netback. The older one  I could see X netback threads eating
> > > 80%
> > >    of CPU. With this one, the number is down to 13-14%. 
> > 
> > "CPU banding problem"?
> > 
> > If you had X threads using 80% before do you now see Y threads using
> > 13-14% where Y is bigger or smaller than X? Is 80*X ~= 13*Y?
> 
> Yes. ~=. The count looked to be the same.

Great, that's as expected, the same work is more fairly distributed -- I
thought you might be suggesting the total had gone down from
X*80%->X*13% which is not what I thought this series would be doing!

Ian.
