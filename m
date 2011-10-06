From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH] SELinux: Fix RCU deref check warning in sel_netport_insert()
Date: Thu, 06 Oct 2011 18:51:19 -0400
Message-ID: <4210290.EWfROnk5ys@sifl>
References: <2230709.7n5noARWFd@sifl> <20111003135824.15303.10147.stgit@warthog.procyon.org.uk> <1624.1317821523@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56399 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759329Ab1JFWvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 18:51:25 -0400
Received: by wyg34 with SMTP id 34so3340604wyg.19
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2011 15:51:24 -0700 (PDT)
In-Reply-To: <1624.1317821523@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, October 05, 2011 02:32:03 PM David Howells wrote:
> Paul Moore <paul@paul-moore.com> wrote:
> > We should probably do the same for the security/selinux/netif.c as it
> > uses the same logic; David is this something you want to tackle?
> 
> netif.c doesn't use any rcu_dereference*() function directly, though it does
> use list_for_each_entry_rcu().  However, I'm not sure that's a problem. 
> What is it you're referring to?

My apologies, the netport.c and netif.c code is very, very similar and 
whenever I see a patch just for one of the two it causes a reaction that you 
saw above.  While netif.c has a similar function, sel_netif_insert(), it is 
slightly different and doesn't need a rcu_dereference() ad the netport.c code 
does.

Sorry for the confusion.

-- 
paul moore
www.paul-moore.com
