From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 17:54:36 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF3B7@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
	Joshua Brindle <method@gentoo.org>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, kmacmillan@mentalrootkit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:28774 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1422840AbWI2VzD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 17:55:03 -0400
To: James Morris <jmorris@namei.org>, Paul Moore <paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Venkat,
> 
> With xfrm labeling, the external packets are always going to 
> be protocol 
> ESP or AH, and we can't connection track the inner protocols.  So, 

Are you sure? This doesn't compare to what my limited testing seems
to have turned up (normal netfiltering of inner protos followed by xfrms,
interspersed with their own netfiltering).

> external labeling when using xfrm labeling seems somewhat 
> superfluous, 
> except for the case of setting a label based on the interface 
> the packets 
> arrived on.  Correct?  If so, all you can realistically do 
> with the flow 
> permissions is bind the ESP/AH packets to types of interfaces 
> (which does 
> seem useful for some folk).
