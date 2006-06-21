From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 01/06] MLSXFRM: Granular IPSec associations for use in
 MLS environments
Date: Wed, 21 Jun 2006 01:24:39 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606210113090.5693@d.namei>
References: <44983D1F.1050306@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:38355 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750950AbWFUFYo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 01:24:44 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <44983D1F.1050306@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 20 Jun 2006, Venkat Yekkirala wrote:

> The current approach to labeling Security Associations for SELinux 
> purposes uses a one-to-one mapping between xfrm policy rules and 
> security associations. This doesn?t address the needs of real world MLS 
> (Multi-level System, traditional Bell-LaPadula) environments where a 
> single xfrm policy rule (pertaining to a range, classified to secret for 
> example) might need to map to multiple Security Associations (one each 
> for classified, secret, top secret and all the compartments applicable 
> to these security levels).

Can you clarify whether, with this patch, Linux will then have a complete 
labeled network implementation in terms of both LSPP compliance and common 
user requirements?

> Outstanding items/issues: 
> - Timewait acknowledgements and such are generated in the 
> current/upstream implementation using a NULL socket resulting in the 
> any_socket sid (SYSTEM_HIGH) to be used. This problem is not addressed 
> by this patch set.

This needs to be resolved, along with labeling for all kernel owned 
socket/tw objects.  I'm not entirely clear on why this doesn't already 
work, as it is using IPsec, which should certainly be able to encapsulate 
all of this traffic.

It would also be interesting to know what kind of testing this code as 
had.


- James
-- 
James Morris
<jmorris@namei.org>
