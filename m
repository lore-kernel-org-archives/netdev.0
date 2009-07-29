From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v6)
Date: Wed, 29 Jul 2009 07:49:15 -0700
Message-ID: <87bpn3o87o.fsf@caffeine.danplanet.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com>
	<1248295301-30930-6-git-send-email-danms@us.ibm.com>
	<4A6F2D62.9040005@librato.com> <87ljm8czsf.fsf@caffeine.danplanet.com>
	<4A6F6B19.9010508@librato.com> <20090729133606.GB31730@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oren Laadan <orenl@librato.com>, containers@lists.osdl.org,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:57796 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750961AbZG2OtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 10:49:17 -0400
In-Reply-To: <20090729133606.GB31730@us.ibm.com> (Serge E. Hallyn's message of "Wed\, 29 Jul 2009 08\:36\:06 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SH> At the moment you miss out on the security_socket_connect() call. 

Is that any different than the path involved when a process does a
socketpair() call?

SH> Still your code is so customized that perhaps an explicit
SH> security_socket_connect() call in your sock_unix_join() may be the
SH> way to go...

So, when I do the join, I really should run the check on both the
remote and local addresses, right?  The join operation is not really a
connect in the sense of being one-sided...

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
