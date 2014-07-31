From: "Abodunrin, Akeem G" <akeem.g.abodunrin@intel.com>
Subject: RE: [net-next 06/15] i40e: Move some variable declarations out of a
 loop
Date: Thu, 31 Jul 2014 23:56:19 +0000
Message-ID: <CFEEE81102D91947B9CC368106979EBA479BEBE6@ORSMSX105.amr.corp.intel.com>
References: <1406766731-4209-1-git-send-email-aaron.f.brown@intel.com>
	<1406766731-4209-7-git-send-email-aaron.f.brown@intel.com>
 <20140731.140559.2090702986159656213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>,
	"Brown, Aaron F" <aaron.f.brown@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:20219 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751759AbaGaX43 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 19:56:29 -0400
In-Reply-To: <20140731.140559.2090702986159656213.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, July 31, 2014 2:06 PM
> To: Brown, Aaron F
> Cc: Abodunrin, Akeem G; netdev@vger.kernel.org; gospo@redhat.com;
> sassmann@redhat.com
> Subject: Re: [net-next 06/15] i40e: Move some variable declarations out of a
> loop
> 
> From: Aaron Brown <aaron.f.brown@intel.com>
> Date: Wed, 30 Jul 2014 17:32:02 -0700
> 
> > From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
> >
> > Declare some variables once outside of the loop instead of in every
> > iteration of the loop.
> >
> > Change-ID: I436913777c7da3c16dc0031b59e3ffa61de74718
> > Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
> > Tested-by: Jim Young <jamesx.m.young@intel.com>
> > Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
> 
> Why?  Decreasing the scope of variables makes the code easier to understand
> and audit.
> 
> Now that it's declared at the top level people have to check whether is it
> initialized properly in all possible code paths, in the entire function, rather than
> just inside of the loop.
> 
> Please respin this series with this patch removed, thanks.

This is done because other codes have to use it before the loop...

Hope you understand the reason for this - and that is how it supposed to be originally, we have to increase the scope of the variables so that other code that are not in the loop can use it.

Regards,
~Akeem G Abodunrin
