From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Thu, 22 Mar 2007 20:56:50 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0703222056080.25271@d.namei>
References: <200703221835.l2MIZdDw007850@faith.austin.ibm.com>
 <20070322.120139.74735307.davem@davemloft.net>  <1174598630.3085.285.camel@faith.austin.ibm.com>
  <Line.LNX.4.64.0703221943110.24461@d.namei> <1174607451.3085.290.camel@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, vyekkirala@trustedcs.com
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:59273 "EHLO
	mail3.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934220AbXCWA4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 20:56:53 -0400
In-Reply-To: <1174607451.3085.290.camel@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Mar 2007, Joy Latten wrote:

> > Perhaps a better semantic would be to fail the entire flush operation if 
> > one of the security checks failed.  e.g. loop through for permissions 
> > first, then if all ok, loop through for deletion.
> > 
> Ok, will code this up and test it if there are no objections.

I'd suggest making the permission loop a noop if CONFIG_SECURITY=n, via a 
static inline function.


-- 
James Morris
<jmorris@namei.org>
