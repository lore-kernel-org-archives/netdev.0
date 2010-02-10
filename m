From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/4] C/R: Basic support for network namespaces and devices (v3)
Date: Wed, 10 Feb 2010 09:38:32 -0800
Message-ID: <87pr4dgfdz.fsf@caffeine.danplanet.com>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
	<1265750713-15749-3-git-send-email-danms@us.ibm.com>
	<20100210172405.GB12251@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:52555 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755894Ab0BJRig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 12:38:36 -0500
In-Reply-To: <20100210172405.GB12251@us.ibm.com> (Serge E. Hallyn's message of "Wed\, 10 Feb 2010 11\:24\:05 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SH> What exactly is this == 0 case?  Does it mean 'use inherited
SH> netns'?

It means it wasn't in the checkpoint image to begin with, so yeah,
kinda.

SH> Don't you then still need to 

SH> 	get_net(current->nsproxy->net_ns);
SH>     nsproxy-> net_ns = current->nsproxy->net_ns;

Yes, I'll unify that path a bit.  Thanks.

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
