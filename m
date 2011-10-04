From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH] SELinux: Fix RCU deref check warning in sel_netport_insert()
Date: Mon, 03 Oct 2011 20:06:59 -0400
Message-ID: <1743108.Ii53PKTyVY@olly>
References: <2230709.7n5noARWFd@sifl> <20111003135824.15303.10147.stgit@warthog.procyon.org.uk> <25906.1317683262@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7Bit
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:52294 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602Ab1JDAHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 20:07:05 -0400
Received: by vws1 with SMTP id 1so3288887vws.19
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2011 17:07:03 -0700 (PDT)
In-Reply-To: <25906.1317683262@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, October 4, 2011 12:07:42 AM David Howells wrote:
> Paul Moore <paul@paul-moore.com> wrote:
> > We should probably do the same for the security/selinux/netif.c as it
> > uses the same logic; David is this something you want to tackle?
> 
> I can have a look, but it won't be before Wednesday.

Not a problem, if you don't get to it just let me know and I'll put together a 
patch.

Thanks.

-- 
paul moore
www.paul-moore.com
