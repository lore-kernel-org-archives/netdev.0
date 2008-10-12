From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [linux-cifs-client] Fwd: [PATCH] Fix CIFS compilation with
 CONFIG_KEYS unset
Date: Sun, 12 Oct 2008 09:59:03 -0400
Message-ID: <20081012095903.33427ee8@tleilax.poochiereds.net>
References: <200810121315.37203.rjw@sisk.pl>
	<524f69650810120640v41778375wf0a7662e773da26f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, "David Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org,
	"samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
	"linux-cifs-client@lists.samba.org"
	<linux-cifs-client@lists.samba.org>, cooldavid@cooldavid.org,
	LKML <linux-kernel@vger.kernel.org>
To: "Steve French" <smfrench@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45445 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752010AbYJLN7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Oct 2008 09:59:33 -0400
In-Reply-To: <524f69650810120640v41778375wf0a7662e773da26f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 12 Oct 2008 08:40:39 -0500
"Steve French" <smfrench@gmail.com> wrote:

> Rafael and Guo-Fu,
> The following change to address the compile error that you noted is
> slightly different than what you suggested but should fix what you
> found.
> 

Actually, I like Adrian/Rafael's fix better. I think we should avoid
cluttering up the code with #ifdef's where possible. key_put() already
is a no-op when CONFIG_KEYS is disabled. We might as well do the same
thing with key_revoke().

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
