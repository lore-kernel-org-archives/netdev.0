From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 0/3] labeled-ipsec: Repost patchset with updates [Originally:
 mlsxfrm: Various Fixes]
Date: Thu, 9 Nov 2006 01:30:05 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0611090124570.11016@d.namei>
References: <45526241.10805@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:20156 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1754742AbWKIGaI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 01:30:08 -0500
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <45526241.10805@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 8 Nov 2006, Venkat Yekkirala wrote:

> This patchset is against davem's net-2.6.git. Please apply to 2.6.19.
> 
> The following are the changes since the previous post of this patchset:
> 
> 1. Separate BUG_ON usage per Eric's suggestion.
> 
> 2. Replace security_sid_compare with a simple sid compare check per
>    a suggestion from Paul/Stephen.

Applied to:
git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/selinux-net-2.6.20.git

I think this should be aimed at 2.6.20, because we are at the last or 
second-last -rc currently, and I don't think these fixes are urgent enough 
to justify the risk at this stage.  Also, I think this code needs more 
testing, and more general progress towards code completion.


- James
-- 
James Morris
<jmorris@namei.org>
