From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] SELinux: Fix RCU deref check warning in sel_netport_insert()
Date: Wed, 05 Oct 2011 14:32:03 +0100
Message-ID: <1624.1317821523@redhat.com>
References: <2230709.7n5noARWFd@sifl> <20111003135824.15303.10147.stgit@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, selinux@tycho.nsa.gov, netdev@vger.kernel.org
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1053 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934670Ab1JENc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 09:32:59 -0400
In-Reply-To: <2230709.7n5noARWFd@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Moore <paul@paul-moore.com> wrote:

> We should probably do the same for the security/selinux/netif.c as it uses
> the same logic; David is this something you want to tackle?

netif.c doesn't use any rcu_dereference*() function directly, though it does
use list_for_each_entry_rcu().  However, I'm not sure that's a problem.  What
is it you're referring to?

David
