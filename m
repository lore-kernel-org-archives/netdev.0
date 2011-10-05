From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] SELinux: Fix RCU deref check warning in sel_netport_insert() [ver #2]
Date: Wed, 05 Oct 2011 12:19:39 +0100
Message-ID: <30594.1317813579@redhat.com>
References: <20111005110843.30324.19133.stgit@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, selinux@tycho.nsa.gov, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46563 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934411Ab1JELUy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 07:20:54 -0400
In-Reply-To: <20111005110843.30324.19133.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Howells <dhowells@redhat.com> wrote:

> +				spin_is_locked(&sel_netport_lock)),

Oops...  I forgot to commit the change.

David
