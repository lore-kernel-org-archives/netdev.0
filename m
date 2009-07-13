From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/2] c/r: Add AF_INET support (v3)
Date: Mon, 13 Jul 2009 12:10:28 -0700
Message-ID: <87zlb8l7q3.fsf@caffeine.danplanet.com>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>
	<1246994776-1882-3-git-send-email-danms@us.ibm.com>
	<1247511728.15106.1.camel@merlyn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	Oren Laaden <orenl@cs.columbia.edu>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:42348 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754686AbZGMTKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2009 15:10:30 -0400
In-Reply-To: <1247511728.15106.1.camel@merlyn> (John Dykstra's message of "Mon\, 13 Jul 2009 14\:02\:08 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

JD> Why?  It seems that this would cause checkpoints to fail
JD> unexpectedly,

Well, there are other places where the checkpoint will fail with EBUSY
because something is in a transitional state.

JD> and is probably unnecessary in a migration scenario, because the
JD> peer will retransmit the segments given appropriate ACKs.

Cool, sounds like we can punt on this particular one... Thanks :)

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
