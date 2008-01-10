From: Karsten Keil <kkeil@suse.de>
Subject: Re: Linux IPv6 DAD not full conform to RFC 4862 ?
Date: Thu, 10 Jan 2008 12:16:19 +0100
Message-ID: <20080110111619.GA5065@pingi.kke.suse.de>
References: <20080109153656.GA16962@pingi.kke.suse.de> <20080109161748.GA25106@hmsreliant.think-freely.org> <20080109202653.GA26160@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:58777 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752958AbYAJLQV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 06:16:21 -0500
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 2E5882689F
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 12:16:20 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20080109202653.GA26160@pingi.kke.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
On Wed, Jan 09, 2008 at 09:26:53PM +0100, Karsten Keil wrote:
> > 
> > Reading the section you reference, we do follow all the MUST requirements, and
> > we log an error.  Given that the disable section is a SHOULD, I think we can at
> > least be somewhat more restrictive in our implementation.  Perhaps we should
> > just disable the interface iff the failed address is link-local AND there are no
> > other functional address assigned to the interface.
> 
> I agree here, but it seems that currently the IPv6 Logo Committee thinks
> that it has to be disable the interface to get the IPv6 ready Logo in
> future. I already claim that on a discussion at the TAHI users list.
> 

JFYI, here the answer from the TAHI list.

    Hi, Karsten.

    Thanks for your comments.

    I know that it is SHOULD,
    but our test tool supports the test specification
    published by IPv6 Ready Logo Program <http://www.ipv6ready.org/>,
    and basically the test specification supports all of MUST and SHOULD.

    You may know,
    now IPv6 Ready Logo Committee is also discussing
    about the next major revision up of test specification.


    RFC 4862 Section 5.4.5 is one of discussing point.

    The public review has been over,
    but if you have strong concern about it,
    I recommend to comment to <ipv6ready-info@ipv6ready.org>.

    Personally,
    I think that mandating this function is the best way.
    But vendor's input will really important for them.

    Regards,
    Yukiyo Akisada


So it would be good if some of the networking experts complain there.

-- 
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex, HRB 16746 (AG Nuernberg)
