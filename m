From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 3/5] Add checkpoint support for veth devices (v2)
Date: Mon, 22 Feb 2010 13:01:15 -0800
Message-ID: <87ocjh6l44.fsf@caffeine.danplanet.com>
References: <1266336187-19105-1-git-send-email-danms@us.ibm.com>
	<1266336187-19105-4-git-send-email-danms@us.ibm.com>
	<20100222195647.GB13135@us.ibm.com>
	<87sk8t6msb.fsf@caffeine.danplanet.com>
	<20100222205738.GA18038@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:43565 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753934Ab0BVVBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 16:01:17 -0500
In-Reply-To: <20100222205738.GA18038@us.ibm.com> (Serge E. Hallyn's message of "Mon\, 22 Feb 2010 14\:57\:38 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SH> So do you actually know that the peer's netns will have been
SH> checkpointed?  I'm a little fuzzy about where netns and netdevs
SH> are checkpointed.  If you have two private netns's in a container,
SH> with a veth connecting them, and you checkpoint a task in netns 1,
SH> will you fail bc netns 2 hasn't been checkpointed yet bc no task
SH> in it has been checkpointed yet?

Nope, because they're collect()'ed before we checkpoint().

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
