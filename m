From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 0/3] Fix for IPsec leakage with SELinux enabled - V.03
Date: Thu, 5 Oct 2006 17:21:47 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CFB64@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'selinux@tycho.nsa.gov'" <selinux@tycho.nsa.gov>,
	"'jmorris@namei.org'" <jmorris@namei.org>,
	"'sds@tycho.nsa.gov'" <sds@tycho.nsa.gov>,
	"'eparis@redhat.com'" <eparis@redhat.com>,
	"'johnpol@2ka.mipt.ru'" <johnpol@2ka.mipt.ru>,
	"'herbert@gondor.apana.org.au'" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:31580 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1751397AbWJEVWG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 17:22:06 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	"'David Miller'" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > This version takes into account David Miller's comments
> > > regarding treatment of security layer errors in the case
> > > of socket policies. Specifically, these errors will be
> > > treated like how these kind of errors are treated for
> > > the main/sub policies, which is to return a full lookup
> > > failure.
> > 
> > I only have patches "1" and "3" in my inbox, did you forget
> > to send the second one out or are they simply misnumbered?
> > 
> 
> My apologies. The second one is also numbered 1, but has the
> following distinct subject line:
> [PATCH 1/3] Fix for IPsec leakage with SELinux enabled - 
> V.03: Fix xfrm code

In actuality, patch 2 in the series has the following subject line:

[PATCH 1/3] Fix for IPsec leakage with SELinux enabled - V.03
