From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH] Fix for IPsec leakage with SELinux enabled
Date: Mon, 2 Oct 2006 14:59:47 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF537@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Paul Moore <paul.moore@hp.com>,
	Chad Hanson <chanson@TrustedCS.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:13635 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S965073AbWJBTA4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 15:00:56 -0400
To: James Morris <jmorris@namei.org>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > This is indeed the "designed" and expected (for me) behavior.
> 
> This is a security hole.  SELinux denies all access by 
> default, so the 
> default behavior of this code is to allow all traffic to bypass IPsec.
> 
> You should not need to add a rule to 'allow' increased security.

You are right. Currently working on a patch (should be out
tonight/tomorrow).

<snip>

> This needs to be handled within SELinux as far as possible, 
> and errors 
> will generally need to be propagated back to the callers, as 

Agreed here as well. I have yet to review your patch in depth,
but it definitely makes sense to do what you say here. Thanks.

> we don't know 
> what other LSMs might do, and errors unrelated to access 
> control can be 
> returned.
> 
> 
> - James
> -- 
> James Morris
> <jmorris@namei.org>
> 
