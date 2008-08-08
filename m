From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: Strange tg3 regression with UMP fw. link reporting
Date: Fri, 08 Aug 2008 13:20:12 -0700
Message-ID: <1218226812.12081.19.camel@HP1>
References: <1218180939.24157.332.camel@pasglop>
 <31233EB5-037E-4615-95C9-7C816E510752@kernel.crashing.org>
 <1218187111.24157.336.camel@pasglop>
 <20080808184359.GB23249@HP-xw6200.broadcom.net>
 <1218233157.24157.343.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Segher Boessenkool" <segher@kernel.crashing.org>,
	"linuxppc-dev list" <linuxppc-dev@ozlabs.org>,
	netdev <netdev@vger.kernel.org>, "Nathan Lynch" <ntl@pobox.com>
To: "benh@kernel.crashing.org" <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4468 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753915AbYHIAVO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 20:21:14 -0400
In-Reply-To: <1218233157.24157.343.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-08-08 at 15:05 -0700, Benjamin Herrenschmidt wrote:
> On Fri, 2008-08-08 at 11:43 -0700, Matt Carlson wrote:
> > We really shouldn't be displaying any error messages in the event of a
> > timeout though.  Earlier versions of the UMP firmware did not support
> > the link update interface.  The best thing the driver can do for all
> > cases is give the firmware a chance to service the event but continue
> > as if the event were serviced if it did not get an explicit ACK.
> 
> But that means that the driver will continuously spin 2.5ms every
> timer tick or so ? Or do I miss something ? Could it be possible to
> count timeouts and if after N attempts at an ack, they all timed out,
> disable the feature completely ?

Please see my other email.  Matt and I will fix it in a way to minimize
the spin as much as possible regardless of firmware version.

> 
> Or is there a way to test the version of the firmware ?
> 
> In any case, the fix should go into -stable as the problem is hurting
> 2.6.26. Also, should we consider updating the tg3 firmware on those
> machines ?
> 

Right, we'll take care of -stable as well.  Thanks.


