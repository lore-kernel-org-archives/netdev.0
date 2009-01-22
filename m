From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 9/9] bnx2x: annotate nvram dword reading/writing
Date: Thu, 22 Jan 2009 22:57:22 +0200
Message-ID: <1232657842.31321.4.camel@lb-tlvb-eliezer>
References: <1232517051.9701.27.camel@brick>
 <1232646600.29087.90.camel@lb-tlvb-eliezer>
 <1232648322.9701.55.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: "Harvey Harrison" <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1280 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751730AbZAVU6c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 15:58:32 -0500
In-Reply-To: <1232648322.9701.55.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-01-22 at 10:18 -0800, Harvey Harrison wrote:
> On Thu, 2009-01-22 at 19:50 +0200, Eilon Greenstein wrote:
> > On Tue, 2009-01-20 at 21:50 -0800, Harvey Harrison wrote:
> > > I believe this exposed an endian bug as the shifting of
> > > bytes from the data buffer was done in cpu-order, then
> > > masked into a be32 and the combined value was then converted
> > > to cpu-order, this does all the masking in be-byteorder and
> > > passes a cpu-ordered value to the write routine.
> > > 
> > > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> > 
> > This change is breaking the FW upgrade utility which uses this interface
> > since it is changing the content. I will need to work with the engineer
> > that owns this utility, but this change will probably stay out for a
> > while
> > 
> 
> No worries, can you explain briefly what the code is trying to accomplish?
> Maybe it was written assuming a le-machine, because this is going to
> work differently on a be-machine.
> 
> Harvey

The utility simply works with the current implementation (on both be and
le) and this is why changing the logic breaks it. I will look into it to
see if we can change the utility logic as well (maybe according to the
driver version) - it is not that easy since this utility supports other
drivers as well.

Harvey - thanks again for this patch, it is definitely a step in the
right direction.

Eilon


