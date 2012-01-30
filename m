From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [RFC PATCH V2] New Xen netback implementation
Date: Mon, 30 Jan 2012 10:21:09 -0500
Message-ID: <20120130152109.GA17923@phenom.dumpdata.com>
References: <1326808024-3744-1-git-send-email-wei.liu2@citrix.com>
 <20120127192214.GA14437@phenom.dumpdata.com>
 <1327936037.26983.241.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:22769 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742Ab2A3PXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 10:23:45 -0500
Content-Disposition: inline
In-Reply-To: <1327936037.26983.241.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2012 at 03:07:16PM +0000, Ian Campbell wrote:
> On Fri, 2012-01-27 at 19:22 +0000, Konrad Rzeszutek Wilk wrote:
> > 
> >  - This patch set solves the CPU banding problem I've seen with the
> >    older netback. The older one  I could see X netback threads eating
> > 80%
> >    of CPU. With this one, the number is down to 13-14%. 
> 
> "CPU banding problem"?
> 
> If you had X threads using 80% before do you now see Y threads using
> 13-14% where Y is bigger or smaller than X? Is 80*X ~= 13*Y?

Yes. ~=. The count looked to be the same.

> 
> Ian.
