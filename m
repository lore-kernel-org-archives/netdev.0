From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH, RFC] Extend smc911x to support LAN921x chips
Date: Sun, 12 Oct 2008 09:38:57 +0200
Message-ID: <87vdvy2rfy.fsf@macbook.be.48ers.dk>
References: <OFFEAB9876.D4A121DB-ON802574BF.0052D905-802574BF.0054D4AE@smsc.com>
	<87vdx5gjzo.fsf@macbook.be.48ers.dk>
	<Pine.LNX.4.64.0810110125540.10196@axis700.grange>
	<871vynr3yb.fsf@macbook.be.48ers.dk>
	<Pine.LNX.4.64.0810111057030.4425@axis700.grange>
	<87k5cfoz7b.fsf@macbook.be.48ers.dk>
	<Pine.LNX.4.64.0810112223160.4965@axis700.grange>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve.Glendinning@smsc.com, netdev@vger.kernel.org,
	Ian.Saturley@smsc.com
To: Guennadi Liakhovetski <lg@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:13914 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751190AbYJLHjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2008 03:39:01 -0400
Received: by nf-out-0910.google.com with SMTP id d3so524069nfc.21
        for <netdev@vger.kernel.org>; Sun, 12 Oct 2008 00:38:59 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0810112223160.4965@axis700.grange> (Guennadi Liakhovetski's message of "Sat\, 11 Oct 2008 22\:30\:57 +0200 \(CEST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Guennadi" == Guennadi Liakhovetski <lg@denx.de> writes:

 Guennadi> On Sat, 11 Oct 2008, Peter Korsgaard wrote:
 >> >>>>> "Guennadi" == Guennadi Liakhovetski <lg@denx.de> writes:
 >> 
 >> Hi,
 >> 
 Guennadi> On Sat, 11 Oct 2008, Peter Korsgaard wrote:
 >> >> >>>>> "Guennadi" == Guennadi Liakhovetski <lg@denx.de> writes:
 >> >> 
 >> >> It looks good, but you should definately split out the arm and cleanup
 >> >> stuff from the new IDs.
 >> 
 Guennadi> You mean remove the new IDs? Why?
 >> 
 >> No, just have them in seperate patches - They are independent of each
 >> other, so no need to put in the same patch.

 Guennadi> No, they are not independent. smc91x.c is comparing the ID
 Guennadi> read from the hardware with the table, which someone
 Guennadi> strangely enough for me put in the header. So, even if one
 Guennadi> were to split them, you would have to make it a patch
 Guennadi> series and make the patch for .c depend on the one for .h
 Guennadi> adding IDs. So, no, these two belong into one patch.

I think we're talking past eachother. The changes in smc911x.c and
smc911x.h to support the new IDs should ofcourse be in the same patch,
but the other changes not - E.G. you end up with a patch series like:

- fix ext phy support
- cleanup debug print
- add 921x support
- pcm037 smc911x support

The first 3 goes to Jeff, and the last one to Russell.

 >> Ahh, the good old break-only-escapes-the-innermost-scope. That's a
 >> good fix, but please send it seperately from the patch adding the new
 >> IDs.

 Guennadi> Ok... it is a simple enough fix, so, one could put them
 Guennadi> both in one patch and be done with them, just explaining
 Guennadi> both in the patch description, but ok, I can make it a
 Guennadi> separate patch too...

I would prefer a seperate patch.

-- 
Bye, Peter Korsgaard
