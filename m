From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 10:39:14 -0400
Message-ID: <1159540754.8496.62.camel@moss-spartans.epoch.ncsc.mil>
References: <451C85F4.7000406@trustedcs.com>  <451C9897.6030306@gentoo.org>
	 <1159534759.8496.1.camel@moss-spartans.epoch.ncsc.mil>
	 <1159538414.3592.5.camel@twoface.columbia.tresys.com>
	 <1159540113.8496.59.camel@moss-spartans.epoch.ncsc.mil>
	 <Pine.LNX.4.64.0609291030520.5023@d.namei>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Joshua Brindle <method@gentoo.org>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov, paul.moore@hp.com,
	kmacmillan@mentalrootkit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mummy.ncsc.mil ([144.51.88.129]:3309 "EHLO jazzhorn.ncsc.mil")
	by vger.kernel.org with ESMTP id S1751119AbWI2OiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 10:38:12 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0609291030520.5023@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-09-29 at 10:33 -0400, James Morris wrote:
> On Fri, 29 Sep 2006, Stephen Smalley wrote:
> 
> > However, since the transition was removed in the flow_out case, it would
> > be logical to remove it from the flow_in case as well, and that would
> > have the side benefit of less overhead.
> 
> How about adding secmark transitions later, if needed, perhaps with an 
> /selinux config control ?
> 
> It does keep things simpler for now, in terms of getting this code merged, 
> deployed into distros and likely certified.

Fine with me, unless Venkat has an immediate use case for such
transitions in the flow_in case (but I think this is mostly my fault for
suggesting transitions a while ago).

-- 
Stephen Smalley
National Security Agency

