From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next 2/4] xen-netback: add control protocol
 implementation
Date: Tue, 10 May 2016 13:46:37 +0000
Message-ID: <2b84a597233447729451e356281c5652@AMSPEX02CL03.citrite.net>
References: <1462447170-1815-1-git-send-email-paul.durrant@citrix.com>
 <1462447170-1815-3-git-send-email-paul.durrant@citrix.com>
 <20160510132918.GD12241@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:13353 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbcEJNrG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 09:47:06 -0400
In-Reply-To: <20160510132918.GD12241@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Liu [mailto:wei.liu2@citrix.com]
> Sent: 10 May 2016 14:29
> To: Paul Durrant
> Cc: xen-devel@lists.xenproject.org; netdev@vger.kernel.org; Wei Liu
> Subject: Re: [PATCH net-next 2/4] xen-netback: add control protocol
> implementation
> 
> On Thu, May 05, 2016 at 12:19:28PM +0100, Paul Durrant wrote:
> > My recent patch to include/xen/interface/io/netif.h defines a new shared
> > ring (in addition to the rx and tx rings) for passing control messages
> > from a VM frontend driver to a backend driver.
> >
> > A previous patch added the necessary boilerplate for mapping the control
> > ring from the frontend, should it be created. This patch adds
> > implementations for each of the defined protocol messages.
> >
> > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> > Cc: Wei Liu <wei.liu2@citrix.com>
> > ---
> >  drivers/net/xen-netback/Makefile    |   2 +-
> >  drivers/net/xen-netback/common.h    |  43 +++++
> >  drivers/net/xen-netback/hash.c      | 361
> ++++++++++++++++++++++++++++++++++++
> >  drivers/net/xen-netback/interface.c |  28 +++
> >  drivers/net/xen-netback/netback.c   |  49 ++++-
> >  5 files changed, 480 insertions(+), 3 deletions(-)
> >  create mode 100644 drivers/net/xen-netback/hash.c
> >
> 
> Other than the issue mentioned by David, the code looks OK to me.
> 

Cool, thanks. I should have the RCU-based hash code done in the next day or so.

  Paul

> Wei.
