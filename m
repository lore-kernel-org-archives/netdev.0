From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH net-next] tipc: cleanup function namespace
Date: Fri, 15 Oct 2010 12:59:13 -0400
Message-ID: <0434463FDA60A94FA978ACA44617682DEE84603056@EUSAACMS0702.eamcs.ericsson.se>
References: <20101013162652.GF31379@hmsreliant.think-freely.org>
 <4CB5E79B.4060507@windriver.com>
 <20101013.142834.226768662.davem@davemloft.net>
 <20101013162035.0c2e8123@nehalam> <4CB64D7C.1080004@windriver.com>
 <20101014012951.GA2186@localhost.localdomain>
 <4CB74391.9020400@windriver.com> <20101014113320.7720828f@nehalam>
 <20101014214426.GA9236@windriver.com> <20101014151333.1446a90c@nehalam>
 <20101015110122.GD22294@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"allan.stephens@windriver.com" <allan.stephens@windriver.com>
To: Neil Horman <nhorman@tuxdriver.com>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr3.ericy.com ([198.24.6.13]:49559 "EHLO imr3.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756093Ab0JOQ7c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 12:59:32 -0400
In-Reply-To: <20101015110122.GD22294@hmsreliant.think-freely.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<...>
> > > diff --git a/Documentation/feature-removal-schedule.txt 
> > > b/Documentation/feature-removal-schedule.txt
> > > index f456389..1def37e 100644
> > > --- a/Documentation/feature-removal-schedule.txt
> > > +++ b/Documentation/feature-removal-schedule.txt
> > > @@ -573,3 +573,15 @@ Why:	Hareware scan is the prefer 
> method for iwlwifi devices for
> > >  Who:	Wey-Yi Guy <wey-yi.w.guy@intel.com>
> > >  
> > >  ----------------------------
> > > +
> > > +What:	TIPC: Delete all code and exported symbols 
> specific to Native API
> > > +When:	March 2011
> > > +Why:	The TIPC Native API, as described here:
> > > +	
> http://tipc.sourceforge.net/doc/tipc_1.7_prog_guide.html#native_api
> > > +	is implemented by exporting a bunch of otherwise unused 
> functions
> > > +	for possible modular linkage by custom end-user code.  This goes
> > > +	against the general concept that the kernel should not be libc.
> > > +
> > > +Who:	Paul Gortmaker <paul.gortmaker@windriver.com>
> > > +	
> > > +----------------------------
> > 
> > Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> > 
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>