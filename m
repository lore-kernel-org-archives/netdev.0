From: Huw Davies <huw@codeweavers.com>
Subject: Re: [RFC PATCH 00/17] CALIPSO implementation
Date: Tue, 22 Dec 2015 17:40:55 +0000
Message-ID: <20151222174055.GB31791@merlot>
References: <1450784813-18304-1-git-send-email-huw@codeweavers.com>
 <56798845.6050703@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.codeweavers.com ([216.251.189.131]:36254 "EHLO
	mail.codeweavers.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752745AbbLVRk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 12:40:59 -0500
Content-Disposition: inline
In-Reply-To: <56798845.6050703@schaufler-ca.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 22, 2015 at 09:28:37AM -0800, Casey Schaufler wrote:
> On 12/22/2015 3:46 AM, Huw Davies wrote:
> > This patch series implements RFC 5570 - Common Architecture Label IPv6
> > Security Option (CALIPSO).  Its goal is to set MLS sensitivity labels
> > on IPv6 packets using a hop-by-hop option.  CALIPSO very similar to
> > its IPv4 cousin CIPSO and much of this series is based on that code.
> 
> There's a one line change to the Smack code in 15/17 due to
> a change in the api, but I assume that there has been no
> attempt to verify that this works with Smack. It's not 100%
> clear that this won't break a Smack kernel, but I haven't
> tried it.

That's correct, I've not looked into Smack at all.  I'll
see if I can figure out what's needed.

Huw.
