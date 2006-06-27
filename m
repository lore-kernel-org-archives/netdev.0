From: James Morris <jmorris@namei.org>
Subject: Re: Labeled Networking Requirements and Design (formerly RE: [PATCH
 01/06] MLSXFRM: Granular IPSec associations for use in  MLS environments)
Date: Mon, 26 Jun 2006 20:29:45 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606262004530.26545@d.namei>
References: <44A0684D.9080904@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, davem@davemloft.net,
	sds@tycho.nsa.gov, paul.moore@hp.com, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:42142 "EHLO
	mail6.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1030264AbWF0A3r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 20:29:47 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <44A0684D.9080904@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Jun 2006, Venkat Yekkirala wrote:

> > What we need is a design rationale, some kind of detailed discussion of what
> > the user requirements are and what the plan is for implementing features to
> > meet these requirements.
> 
> The following is not extensive in a formal/theoretical sense, but hopefully
> addresses the need here.

This is great, thanks.  Exactly what was needed and much appreciated.

I think the interaction with secmark as you describe sounds good.

> 3. Patch for ITEM5 has already been done by Eric Paris and is being considered
>   for upstreaming.

This is in Linus' tree now.

> 5. Patch for ITEM7: TCS currently have no plans to design and implement this.
> 

(Datagram labeling)

I guess we'd probably use SCM_SECURITY for this (similar to 
IP_CMSG_PASSEC for receiving the label).

Is this enough support for user API support at the kernel level in terms 
of setting and getting labels?


- James
-- 
James Morris
<jmorris@namei.org>
