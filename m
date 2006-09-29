From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 10:33:11 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609291030520.5023@d.namei>
References: <451C85F4.7000406@trustedcs.com>  <451C9897.6030306@gentoo.org>
  <1159534759.8496.1.camel@moss-spartans.epoch.ncsc.mil>
 <1159538414.3592.5.camel@twoface.columbia.tresys.com>
 <1159540113.8496.59.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joshua Brindle <method@gentoo.org>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov, paul.moore@hp.com,
	kmacmillan@mentalrootkit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:63668 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750929AbWI2OdO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 10:33:14 -0400
To: Stephen Smalley <sds@tycho.nsa.gov>
In-Reply-To: <1159540113.8496.59.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Sep 2006, Stephen Smalley wrote:

> However, since the transition was removed in the flow_out case, it would
> be logical to remove it from the flow_in case as well, and that would
> have the side benefit of less overhead.

How about adding secmark transitions later, if needed, perhaps with an 
/selinux config control ?

It does keep things simpler for now, in terms of getting this code merged, 
deployed into distros and likely certified.


- James
-- 
James Morris
<jmorris@namei.org>
