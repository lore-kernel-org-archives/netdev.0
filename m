From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 12:15:46 -0400
Message-ID: <451D46B2.9010906@hp.com>
References: <451C85F4.7000406@trustedcs.com>  <451C9897.6030306@gentoo.org>  <1159534759.8496.1.camel@moss-spartans.epoch.ncsc.mil>  <1159538414.3592.5.camel@twoface.columbia.tresys.com>  <1159540113.8496.59.camel@moss-spartans.epoch.ncsc.mil>  <Pine.LNX.4.64.0609291030520.5023@d.namei> <1159540754.8496.62.camel@moss-spartans.epoch.ncsc.mil> <451D4475.3020003@hp.com> <Pine.LNX.4.64.0609291209150.5698@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
	Joshua Brindle <method@gentoo.org>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	kmacmillan@mentalrootkit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:21958 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1161124AbWI2QPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 12:15:48 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0609291209150.5698@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Fri, 29 Sep 2006, Paul Moore wrote:
> 
> 
>>Unless I'm confusing something, there still may be a need for transitions
>>if we want to support both IPsec and NetLabel labeling on the same
>>connection.
> 
> I'd prefer not to support this, as it's too complicated, and CIPSO is a 
> legacy protocol.
> 
> Normal IPsec protection applied to CIPSO: yes, but not IPsec labeling and 
> CIPSO labeling on the same connection.

I tend to agree, I just can't see it being all that useful in the real
world.  However, each time it comes up (including the conference call
earlier this week) it seems that people would prefer to use both at the
same time.

The good news is that it sounds like there is a reasonable solution (see
the last email exchance between Venkat and myself).

-- 
paul moore
linux security @ hp
