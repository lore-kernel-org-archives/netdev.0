From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH] [RFC] C/R: inet4 and inet6 unicast routes (v2)
Date: Fri, 30 Apr 2010 13:37:02 -0500
Message-ID: <20100430183702.GA29585@us.ibm.com>
References: <1272646855-17327-1-git-send-email-danms@us.ibm.com>
 <20100430181946.GA26761@us.ibm.com>
 <87mxwkztjf.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:44124 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759088Ab0D3ShH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:37:07 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e37.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3UIZR9h030112
	for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 12:35:27 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3UIb3IP170792
	for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 12:37:03 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3UIdnFr014504
	for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 12:39:49 -0600
Content-Disposition: inline
In-Reply-To: <87mxwkztjf.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):
> SH> So I'm afraid you're going to have to do a slightly uglier thing
> SH> where you unshare_nsproxy_namespaces() and then
> SH> switch_task_namespaces() to the new nsproxy.
> 
> Well, I think that would be hidden in the nicer helper function I
> think I'll need, which I eluded to in the patch header.  This is just
> an RFC proof that it can be done in this manner, but I think a
> separate helper in nsproxy.c is in order to make it nice (and avoid
> the extra alloc/free of the netns that copy_namespaces() will create).
> Agreed?

Yup - thanks!

-serge
