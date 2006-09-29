From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 12:22:46 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF2BA@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
	James Morris <jmorris@namei.org>,
	Joshua Brindle <method@gentoo.org>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, kmacmillan@mentalrootkit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:22565 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932328AbWI2QXJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 12:23:09 -0400
To: Paul Moore <paul.moore@hp.com>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> That's fine by me, I just wanted to make sure something like 
> that would
> be acceptable.  So, in summary, we would do the normal flow_in checks
> for both IPsec and NetLabel and then set the secmark using the IPsec
> label as the "base sid" for the NetLabel's generated SID?

That's correct (in short you won't care if IPSec was in use or not, you
would just use the secmark at that point as the base sid in coming up
with the NetLabel sid, and if it flow controls fine vis a vis the secmark
you would replace secmark with the NetLabel sid. The logic flow is quite
natural and intuitive for the users as well).
