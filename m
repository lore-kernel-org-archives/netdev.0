From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH][RFC] Security marking
Date: Mon, 17 Apr 2006 14:43:15 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0604171440480.17563@d.namei>
References: <Pine.LNX.4.64.0604160012500.16600@d.namei> <4443D5BA.6060605@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:37535 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751201AbWDQSnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 14:43:17 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4443D5BA.6060605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Apr 2006, Patrick McHardy wrote:

> >From a pure netfilter POV it would still be nice to have the socket
> hooks for userspace queueing in socket context and filtering hard
> to track protocols. My only question is: if I would port the skfilter
> patches to the current kernel today and fix the unresolved issues,
> would you still prefer this approach?

I think the newer model of marking the packets first via Netfilter then 
interpreting them at the socket layer is superior.  i.e. skfilter is 
probably not preferred for SELinux now.

However, it's still useful for incoming user matching for things like 
user-level firewalling.


- James
-- 
James Morris
<jmorris@namei.org>
