From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Fri, 23 Mar 2007 14:46:48 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0703231441390.30602@d.namei>
References: <200703221835.l2MIZdDw007850@faith.austin.ibm.com>
 <20070322.120139.74735307.davem@davemloft.net>  <1174598630.3085.285.camel@faith.austin.ibm.com>
  <Line.LNX.4.64.0703221943110.24461@d.namei> <1174628387.10788.53.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joy Latten <latten@austin.ibm.com>,
	David Miller <davem@davemloft.net>, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, vyekkirala@TrustedCS.com
To: Eric Paris <eparis@parisplace.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:56712 "EHLO
	mail7.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753314AbXCWSqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 14:46:52 -0400
In-Reply-To: <1174628387.10788.53.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 23 Mar 2007, Eric Paris wrote:

> Maybe I'm way out on a limb here but if I am a regular user and I say
> rm /tmp/* and I only have permissions to delete some of the files I
> expect just those couple to be delete, not the whole operation denied.

I don't think this analogy holds up, as rm is a per-file deletion 
operation, and it is the shell which expands the wildcard for you.

A 'flush' has a semantic implication that all entries will be removed, and 
it should be atomic and either succeed or fail at that granularity.



- James
-- 
James Morris
<jmorris@namei.org>
