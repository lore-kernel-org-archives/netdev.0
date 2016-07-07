From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [PATCH] xen-netback: correct return value checks on
 xenbus_scanf()
Date: Thu, 7 Jul 2016 10:40:49 +0000
Message-ID: <2cd27672b2ab4244ab6815919b24ac17@AMSPEX02CL03.citrite.net>
References: <577E277C02000078000FBEBB@prv-mh.provo.novell.com>
 <577E27B8.2050603@citrix.com> <20160707103513.GB416@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jan Beulich <JBeulich@suse.com>, Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:39953 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092AbcGGKk4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 06:40:56 -0400
In-Reply-To: <20160707103513.GB416@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Wei Liu
> Sent: 07 July 2016 11:35
> To: David Vrabel
> Cc: Jan Beulich; Wei Liu; xen-devel@lists.xenproject.org;
> netdev@vger.kernel.org
> Subject: Re: [Xen-devel] [PATCH] xen-netback: correct return value checks
> on xenbus_scanf()
> 
> On Thu, Jul 07, 2016 at 10:58:16AM +0100, David Vrabel wrote:
> > On 07/07/16 08:57, Jan Beulich wrote:
> > > Only a positive return value indicates success.
> >
> > This is not correct.
> >

If Xen's vsscanf follows the semantics of scanf(3) then 0 is a failure so I think the comment is correct.

  Paul

> 
> Do you mean the commit message is not correct or the code is not
> correct? If it is the formal, do you have any suggestion to fix it?
> 
> (I was going to just ack this because Paul already reviewed it)
> 
> Wei.
> 
> > David
