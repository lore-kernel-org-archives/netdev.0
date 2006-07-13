From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 08/10] MLSXFRM: Add security context to acquire messages
 using PF_KEY
Date: Thu, 13 Jul 2006 11:24:25 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607131119080.6169@d.namei>
References: <44B56642.6060500@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	tjaeger@cse.psu.edu, selinux@tycho.nsa.gov,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:40580 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S964781AbWGMPY1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 11:24:27 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <44B56642.6060500@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Jul 2006, Venkat Yekkirala wrote:

> This labels the flows that could utilize IPSec xfrms at the points they
> are defined so that IPSec policy and SAs at the right label can be used.
> 
> The following protos are currently not handled, but they should continue
> to be able to use single-labeled IPSec like they currently do.
> 
> ipmr
> ip_gre
> ipip
> igmp
> sit
> sctp
> ip6_tunnel (IPv6 over IPv6 tunnel device)
> decnet
> 

Also, just to bring netdev up to date on this, previous discussion on the 
redhat-lspp list about this patch:

(myself):
> This seems problematic in that it's not a general solution and depends 
> always on hooking in at all of the right places in every protocol.  
> Adding a bunch of hooks to protocol-specific code is what got us in trouble 
> with the initial LSM submission.
>
> What about using secmark and connection tracking for this, instead?


I did get a reply from Venkat but can't find it in the archives, so it may 
have been off-list?

IIRC, the outgoing netfilter hook is in the wrong location.

Venkat, please clarify.


- James
-- 
James Morris
<jmorris@namei.org>
