From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [PATCH net-next] xen-netfront: add support for IPv6
 offloads
Date: Wed, 15 Jan 2014 17:08:25 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD02081B7@AMSPEX01CL01.citrite.net>
References: <1389799111-8372-1-git-send-email-paul.durrant@citrix.com>
 <52D6A868.6040707@citrix.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD0208071@AMSPEX01CL01.citrite.net>
 <52D6BF630200007800113EFB@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Vrabel <david.vrabel@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>,
	Andrew Cooper <Andrew.Cooper3@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:38117 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752571AbaAORJD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 12:09:03 -0500
In-Reply-To: <52D6BF630200007800113EFB@nat28.tlf.novell.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Jan Beulich [mailto:JBeulich@suse.com]
> Sent: 15 January 2014 16:04
> To: Andrew Cooper; Paul Durrant
> Cc: David Vrabel; xen-devel@lists.xen.org; Boris Ostrovsky;
> netdev@vger.kernel.org
> Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: add support for
> IPv6 offloads
> 
> >>> On 15.01.14 at 16:54, Paul Durrant <Paul.Durrant@citrix.com> wrote:
> >> From: Andrew Cooper [mailto:andrew.cooper3@citrix.com]
> >> On 15/01/14 15:18, Paul Durrant wrote:
> >> > +	err = xenbus_printf(xbt, dev->nodename, "feature-gso-tcpv6",
> "%d", 1);
> >>
> >> "%d", 1 results in a constant string.  xenbus_write() would avoid a
> >> transitory memory allocation.
> >
> > This code is consistent with all the other xenbus_printf()s in the
> > neighbourhood and does it really matter?
> 
> I think we should always strive to have the simplest possible code
> that fulfills the purpose. And hence we shouldn't be setting further
> bad precedents. (In fact I have a patch queued to replace all the
> unnecessary xenbus_printf()s with xenbus_write()s on
> linux-2.6.18-xen.hg, and may look into porting this to the
> respective upstream components.)
> 

Ok. Personally I'd go for code consistency with this patch and then a full replacement... but I'll re-work it.

  Paul
