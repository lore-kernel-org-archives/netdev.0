From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v7)
Date: Tue, 4 Aug 2009 16:17:42 -0500
Message-ID: <20090804211742.GC13499@us.ibm.com>
References: <1249331463-11887-1-git-send-email-danms@us.ibm.com> <1249331463-11887-6-git-send-email-danms@us.ibm.com> <20090804205241.GF10275@us.ibm.com> <878whzl2cs.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>,
	netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:59118 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932510AbZHDVRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 17:17:39 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n74LDKax031699
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 15:13:20 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n74LHegx256230
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 15:17:40 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n74LHd8T008552
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 15:17:40 -0600
Content-Disposition: inline
In-Reply-To: <878whzl2cs.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):
> SH> Does this re-use of tmp make sense?  (It only would if
> SH> dev_alloc_skb() did a generic prealloc for any subsequent
> SH> skb_clone() which i don't think is the case)
> 
> No, this is cruft.
> 
> SH> Also, do you need any kind of lock on the queue to make this walk
> SH> safe, or do ensure below (sorry i'm slow and haven't gotten there)
> SH> that all tasks with an open fd for either end of this sock are
> SH> frozen?
> 
> Hmm, it seems that holding the lock while processing the queue isn't
> really the way to go.  Perhaps comparing the pid of the other end of
> the socket against the list in the context is best?

I don't understand.  Which pid?
