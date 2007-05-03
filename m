From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][XFRM] SAD info TLV aggregation
Date: Thu, 03 May 2007 15:15:59 +0200
Message-ID: <4639E08F.5030101@trash.net>
References: <1178144288.4078.5.camel@localhost> <4639298E.8090100@trash.net> <1178197316.4077.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62356 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161927AbXECNRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 09:17:32 -0400
In-Reply-To: <1178197316.4077.4.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Thu, 2007-03-05 at 02:15 +0200, Patrick McHardy wrote:
> 
> 
>>I think using attributes here
> 
> 
> "here" as in SAD or SPD as well?

Both.

>> wasn't a bad idea since this exports
>>things that are implementation details and might need to be changed
>>or extended at some point.
> 
> 
> I think it may be reasonable to group the Hash info in one TLV
> and the IPSEC specific info in a separate TLV - is this what you are
> saying? Be explicit so i dont have to redo the patch over and over.

Yes, thats what I imagined too.

> The other way to look at it is in the future, a new TLV could be added
> that replaces the current one.

It would still make sense to seperate hash related things from the
SA count in my opinion.

>>In any case consistent naming here would be nice (SAD_ vs. SADXXX).
> 
> 
> yes, i need to make this change on the SPD as well. Dave hold onto both
> patches - i will resend.

Thanks.
