From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 12:10:59 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609291209150.5698@d.namei>
References: <451C85F4.7000406@trustedcs.com>  <451C9897.6030306@gentoo.org>
  <1159534759.8496.1.camel@moss-spartans.epoch.ncsc.mil>
 <1159538414.3592.5.camel@twoface.columbia.tresys.com>
 <1159540113.8496.59.camel@moss-spartans.epoch.ncsc.mil>
 <Pine.LNX.4.64.0609291030520.5023@d.namei> <1159540754.8496.62.camel@moss-spartans.epoch.ncsc.mil>
 <451D4475.3020003@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Smalley <sds@tycho.nsa.gov>,
	Joshua Brindle <method@gentoo.org>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	kmacmillan@mentalrootkit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:18324 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932318AbWI2QLB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 12:11:01 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <451D4475.3020003@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Sep 2006, Paul Moore wrote:

> Unless I'm confusing something, there still may be a need for transitions
> if we want to support both IPsec and NetLabel labeling on the same
> connection.

I'd prefer not to support this, as it's too complicated, and CIPSO is a 
legacy protocol.

Normal IPsec protection applied to CIPSO: yes, but not IPsec labeling and 
CIPSO labeling on the same connection.



- James
-- 
James Morris
<jmorris@namei.org>
