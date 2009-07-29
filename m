From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v6)
Date: Tue, 28 Jul 2009 20:56:53 -0500
Message-ID: <20090729015653.GA31730@us.ibm.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com> <1248295301-30930-6-git-send-email-danms@us.ibm.com> <4A6F2D62.9040005@librato.com> <87ljm8czsf.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oren Laadan <orenl@librato.com>, containers@lists.osdl.org,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:53023 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbZG2B4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 21:56:54 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n6T1rS8B019442
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 19:53:28 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n6T1usba248136
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 19:56:54 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6T1urlA001721
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 19:56:54 -0600
Content-Disposition: inline
In-Reply-To: <87ljm8czsf.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):
> OL> Unless/until we decide otherwise, let's keep all ckpt_hdr_xxx
> OL> definitions in a single place -- checkpoint_hdr.h
> 
> That's how I initially had it, but Serge asked for it to be moved into
> the network headers.  Serge?

Yes, it seems to me we want to keep those close to the maintainer's
code rather than expect them to go browsing through cr headers when
they change their own code.

Of course just putting ckpt_hdr_xxx into the subsystems' headers
isn't sufficient - we need to have better discussions with the
maintainers about ways to make maintaining their subsystems with
cr pretty much the same as it was without cr.

-serge
