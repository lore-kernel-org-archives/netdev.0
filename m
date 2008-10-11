From: Guennadi Liakhovetski <lg@denx.de>
Subject: Re: [PATCH, RFC] Extend smc911x to support LAN921x chips
Date: Sat, 11 Oct 2008 22:30:57 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0810112223160.4965@axis700.grange>
References: <OFFEAB9876.D4A121DB-ON802574BF.0052D905-802574BF.0054D4AE@smsc.com>
 <87vdx5gjzo.fsf@macbook.be.48ers.dk> <Pine.LNX.4.64.0810110125540.10196@axis700.grange>
 <871vynr3yb.fsf@macbook.be.48ers.dk> <Pine.LNX.4.64.0810111057030.4425@axis700.grange>
 <87k5cfoz7b.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Steve.Glendinning@smsc.com, netdev@vger.kernel.org,
	Ian.Saturley@smsc.com
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:50437 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753924AbYJKUa6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2008 16:30:58 -0400
In-Reply-To: <87k5cfoz7b.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 11 Oct 2008, Peter Korsgaard wrote:

> >>>>> "Guennadi" == Guennadi Liakhovetski <lg@denx.de> writes:
> 
> Hi,
> 
>  Guennadi> On Sat, 11 Oct 2008, Peter Korsgaard wrote:
>  >> >>>>> "Guennadi" == Guennadi Liakhovetski <lg@denx.de> writes:
>  >> 
>  >> It looks good, but you should definately split out the arm and cleanup
>  >> stuff from the new IDs.
> 
>  Guennadi> You mean remove the new IDs? Why?
> 
> No, just have them in seperate patches - They are independent of each
> other, so no need to put in the same patch.

No, they are not independent. smc91x.c is comparing the ID read from the 
hardware with the table, which someone strangely enough for me put in the 
header. So, even if one were to split them, you would have to make it a 
patch series and make the patch for .c depend on the one for .h adding 
IDs. So, no, these two belong into one patch.

>  >> What's this for? Isn't that handled just above?
> 
>  Guennadi> I think, there's a bug in the code there. The break above
>  Guennadi> terminates the loop, yes, but then it falls through in the
>  Guennadi> switch statement to the default case and overwrites the
>  Guennadi> just found PHY.
> 
> Ahh, the good old break-only-escapes-the-innermost-scope. That's a
> good fix, but please send it seperately from the patch adding the new
> IDs.

Ok... it is a simple enough fix, so, one could put them both in one patch 
and be done with them, just explaining both in the patch description, but 
ok, I can make it a separate patch too...

Thanks
Guennadi
---
Guennadi Liakhovetski, Ph.D.

DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: +49-8142-66989-0 Fax: +49-8142-66989-80  Email: office@denx.de
