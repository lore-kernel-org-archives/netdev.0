From: jamal <hadi@cyberus.ca>
Subject: Re: Question about xfrm by MARK feature
Date: Fri, 25 Jun 2010 08:43:15 -0400
Message-ID: <1277469795.5438.5.camel@bigi>
References: <201006231803.17261.lists@egidy.de>
	 <1277381094.3455.92.camel@bigi>  <201006250935.30967.lists@egidy.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, kaber@trash.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: "Gerd v. Egidy" <lists@egidy.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:64545 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753206Ab0FYMnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 08:43:21 -0400
Received: by vws9 with SMTP id 9so3849221vws.19
        for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 05:43:20 -0700 (PDT)
In-Reply-To: <201006250935.30967.lists@egidy.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gerd,

On Fri, 2010-06-25 at 09:35 +0200, Gerd v. Egidy wrote:

> I planned to avoid looking at the remote gateway ip (to even allow two 
> different remote gateways hiding natted behind the same ip) but that would be 
> a good fallback solution if my other ideas don't work out.
> 

Doesnt have to be a remote IP...
If you can somehow even map a remote to some MAC address or incoming
virtual interface (such as a VLAN) that would do it as well.
Alternatively, you should probably look at namespaces  - i just find it
more usable when you have overlapping/conflicting ip addresses. You
of course will have to run strongswan per namespace if you dont want to
hack strongswan.

cheers,
jamal

