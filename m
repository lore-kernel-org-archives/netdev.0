From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] SELinux: Fix RCU deref check warning in sel_netport_insert()
Date: Wed, 05 Oct 2011 12:07:19 +0100
Message-ID: <23105.1317812839@redhat.com>
References: <1317702176.2784.4.camel@edumazet-laptop> <20111003135824.15303.10147.stgit@warthog.procyon.org.uk> <2230709.7n5noARWFd@sifl>
Cc: dhowells@redhat.com, Paul Moore <paul@paul-moore.com>,
	selinux@tycho.nsa.gov, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9850 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934305Ab1JELIT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 07:08:19 -0400
In-Reply-To: <1317702176.2784.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Usual way is to use :
> 	rcu_dereference_protected(
> 		sel_netport_hash[idx].list.prev,
> 		lockdep_is_held(&sel_netport_lock)),

Good point.

David
