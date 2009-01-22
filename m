From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 1/9] bnx2x: remove a few trivial macros
Date: Thu, 22 Jan 2009 19:50:06 +0200
Message-ID: <1232646606.29087.91.camel@lb-tlvb-eliezer>
References: <1232517046.9701.19.camel@brick>
 <1232522093.29087.9.camel@lb-tlvb-eliezer>
 <20090121.154246.183468953.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "harvey.harrison@gmail.com" <harvey.harrison@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2820 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759447AbZAVRvK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 12:51:10 -0500
In-Reply-To: <20090121.154246.183468953.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-21 at 15:42 -0800, David Miller wrote:
> From: "Eilon Greenstein" <eilong@broadcom.com>
> Date: Wed, 21 Jan 2009 09:14:53 +0200
> 
> > On Tue, 2009-01-20 at 21:50 -0800, Harvey Harrison wrote:
> > > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> > > ---
> > > Eilon, after this series, sparse with endian-checking at least gets through a
> > > compile without hitting too many errors, patch 9 is a functional change
> > > and may have exposed an endian bug in the driver....but I had to get through
> > > the other 8 to see it ;-)
> > > 
> > Wooh!!! Harvey - thanks for all the hard work!
> > 
> > I will review it carefully and start regression tests on few different
> > platforms to verify this fix. Stay tuned.
> 
> Thanks Eilon, once you've validated these changes let me know
> so I can add them to net-next-2.6
> 

Besides the eeprom changes that broke a utility that uses it, this patch
is working just fine. I have few cosmetic issues with le_to_cpu for zero
(which I plan to remove) and I'm not sure if replacing swab with
cpu_to_le on top of be_to_cpu is the way to go - I hope to get some
comments on this one.

Harvey - I truly appreciate your work. I will pack it and resend it
after receiving some comments.

Thanks again,
Eilon


