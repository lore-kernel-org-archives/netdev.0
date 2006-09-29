From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 12:09:44 -0400
Message-ID: <36282A1733C57546BE392885C061859201573D58@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: James Morris <jmorris@namei.org>,
	Joshua Brindle <method@gentoo.org>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	kmacmillan@mentalrootkit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:50286 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932313AbWI2QKd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 12:10:33 -0400
To: Paul Moore <paul.moore@hp.com>, Stephen Smalley <sds@tycho.nsa.gov>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Fine with me, unless Venkat has an immediate use case for such
> > transitions in the flow_in case (but I think this is mostly 
> my fault for
> > suggesting transitions a while ago).

I don't have a use case currently.

> 
> Unless I'm confusing something, there still may be a need for 
> transitions
> if we want to support both IPsec and NetLabel labeling on the same
> connection.
> If we don't support transitions and allow both labeling methods on the
> same connection we'll need to decide how to handle resolving the two -
> maybe use a transition is this one case?

Since CIPSO doesn't do full contexts currently, it would be just a
matter of an additional flow_in check. The base sid used here would
be the current secmark at that point (which will be the xfrm sid
if xfrm was used). So, no transitions needed here currently.
