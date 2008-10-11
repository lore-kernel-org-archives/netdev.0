From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH, RFC] Extend smc911x to support LAN921x chips
Date: Sat, 11 Oct 2008 18:48:08 +0200
Message-ID: <87k5cfoz7b.fsf@macbook.be.48ers.dk>
References: <OFFEAB9876.D4A121DB-ON802574BF.0052D905-802574BF.0054D4AE@smsc.com>
	<87vdx5gjzo.fsf@macbook.be.48ers.dk>
	<Pine.LNX.4.64.0810110125540.10196@axis700.grange>
	<871vynr3yb.fsf@macbook.be.48ers.dk>
	<Pine.LNX.4.64.0810111057030.4425@axis700.grange>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve.Glendinning@smsc.com, netdev@vger.kernel.org,
	Ian.Saturley@smsc.com
To: Guennadi Liakhovetski <lg@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:64298 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753686AbYJKQsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 12:48:14 -0400
Received: by ey-out-2122.google.com with SMTP id 6so388998eyi.37
        for <netdev@vger.kernel.org>; Sat, 11 Oct 2008 09:48:09 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810111057030.4425@axis700.grange> (Guennadi Liakhovetski's message of "Sat\, 11 Oct 2008 11\:00\:40 +0200 \(CEST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Guennadi" == Guennadi Liakhovetski <lg@denx.de> writes:

Hi,

 Guennadi> On Sat, 11 Oct 2008, Peter Korsgaard wrote:
 >> >>>>> "Guennadi" == Guennadi Liakhovetski <lg@denx.de> writes:
 >> 
 >> It looks good, but you should definately split out the arm and cleanup
 >> stuff from the new IDs.

 Guennadi> You mean remove the new IDs? Why?

No, just have them in seperate patches - They are independent of each
other, so no need to put in the same patch.

 >> What's this for? Isn't that handled just above?

 Guennadi> I think, there's a bug in the code there. The break above
 Guennadi> terminates the loop, yes, but then it falls through in the
 Guennadi> switch statement to the default case and overwrites the
 Guennadi> just found PHY.

Ahh, the good old break-only-escapes-the-innermost-scope. That's a
good fix, but please send it seperately from the patch adding the new
IDs.

-- 
Bye, Peter Korsgaard
