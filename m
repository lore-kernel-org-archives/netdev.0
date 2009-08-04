From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 3/5] Add common socket helpers to unify the security	hooks
Date: Tue, 04 Aug 2009 12:43:00 -0700
Message-ID: <87d47bl60r.fsf@caffeine.danplanet.com>
References: <1249331463-11887-1-git-send-email-danms@us.ibm.com>
	<1249331463-11887-4-git-send-email-danms@us.ibm.com>
	<20090804192036.GC10275@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:39640 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752680AbZHDTnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 15:43:03 -0400
In-Reply-To: <20090804192036.GC10275@us.ibm.com> (Serge E. Hallyn's message of "Tue\, 4 Aug 2009 14\:20\:36 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SH> My only concern here is whether 0 should be passed in by the
SH> caller?  (Not sure, just wondering)

I just figured I'd split up the 0/1 case into getname and getpeer,
mirroring the libc calls.  I don't care either way.

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
