From: "Andy Johnson" <johnsonzjo@gmail.com>
Subject: xfrm_lookup() and XFRM_POLICY_ICMP
Date: Thu, 31 Jan 2008 10:42:08 +0200
Message-ID: <147a89290801310042y1c3f926flcf7433835d8d9961@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:30458 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527AbYAaImL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 03:42:11 -0500
Received: by fg-out-1718.google.com with SMTP id e21so530622fga.17
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 00:42:08 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

A question about XFRM_POLICY_ICMP:

 I had tried to understand this check in __xfrm_lookup() method in
  net/xfrm/xfrm_policy.c (the recent 2.6 git dave miller tree):
...
...
		if ((flags & XFRM_LOOKUP_ICMP) && !(policy->flags & XFRM_POLICY_ICMP))
		goto error;
...
...

Why is the check for XFRM_POLICY_ICMP? I had grepped under the kernel tree,
and the only place where XFRM_POLICY_ICMP appears is here (except its definition
in xfrm.h).

I also grepped under openswan tree, and could not find XFRM_POLICY_ICMP.
(the struct xfrm_userpolicy_info  in openswan includes XFRM_POLICY_ALLOW and
XFRM_POLICY_BLOCK and XFRM_POLICY_LOCALOK, but not XFRM_POLICY_ICMP).

I also grepped under iproute2 tree (from git) and there is no XFRM_POLICY_ICMP.

So is this there a way at all to set XFRM_POLICY_ICMP? and if not - maybe this
check is not needed at all ?

Regards,
Andy
