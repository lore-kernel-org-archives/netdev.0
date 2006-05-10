From: James Morris <jmorris@namei.org>
Subject: Re: [RFC][SECMARK 03/08] Add xtables SECMARK target
Date: Wed, 10 May 2006 09:30:00 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605100925340.30577@d.namei>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>
 <Pine.LNX.4.64.0605071134250.8588@d.namei> <44618233.5020704@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:29346 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S964957AbWEJNaD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 09:30:03 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44618233.5020704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 10 May 2006, Patrick McHardy wrote:

> The netfilter parts all look fine too me (just one question,
> see below). Shall I add the userspace parts to SVN or do you
> want to do it yourself?

Might be better if you do it, although I'm still looking into one issue at 
this stage.

> I wonder if the result of this check could be invalidated later
> by removal of the selinux context and if it would matter, since
> you reject contexts not known at initialization time.

If the context is removed later by a change to SELinux policy, the kernel 
will remap them to "unlabeled_t", which is how packets would then be 
labeled by the rule.


- James 
-- 
James Morris <jmorris@namei.org>
