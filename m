From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 12:17:34 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF2B9@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
	Joshua Brindle <method@gentoo.org>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	kmacmillan@mentalrootkit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:60503 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1161127AbWI2QRu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 12:17:50 -0400
To: James Morris <jmorris@namei.org>, Paul Moore <paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Unless I'm confusing something, there still may be a need 
> for transitions
> > if we want to support both IPsec and NetLabel labeling on the same
> > connection.
> 
> I'd prefer not to support this, as it's too complicated,

Actually, from my vantage point, it actually seems "natural".

> and 
> CIPSO is a 
> legacy protocol.

Sure.

> 
> Normal IPsec protection applied to CIPSO: yes, but not IPsec 
> labeling and 
> CIPSO labeling on the same connection.

One use case example can be one SA for Secret in combination with
any/all/none of the compartments. And another SA for Top Secret ...
