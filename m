From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][XFRM] SAD info TLV aggregation
Date: Thu, 03 May 2007 09:01:56 -0400
Message-ID: <1178197316.4077.4.camel@localhost>
References: <1178144288.4078.5.camel@localhost> <4639298E.8090100@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:9993 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161887AbXECNCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 09:02:01 -0400
Received: by wx-out-0506.google.com with SMTP id h31so430220wxd
        for <netdev@vger.kernel.org>; Thu, 03 May 2007 06:02:00 -0700 (PDT)
In-Reply-To: <4639298E.8090100@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-03-05 at 02:15 +0200, Patrick McHardy wrote:

> 
> I think using attributes here

"here" as in SAD or SPD as well?

>  wasn't a bad idea since this exports
> things that are implementation details and might need to be changed
> or extended at some point.

I think it may be reasonable to group the Hash info in one TLV
and the IPSEC specific info in a separate TLV - is this what you are
saying? Be explicit so i dont have to redo the patch over and over.
The other way to look at it is in the future, a new TLV could be added
that replaces the current one.

> In any case consistent naming here would be nice (SAD_ vs. SADXXX).

yes, i need to make this change on the SPD as well. Dave hold onto both
patches - i will resend.

cheers,
jamal



