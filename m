From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/2] c/r: Add AF_INET support (v3)
Date: Fri, 31 Jul 2009 12:40:55 -0700
Message-ID: <87hbwsy720.fsf@caffeine.danplanet.com>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>
	<1246994776-1882-3-git-send-email-danms@us.ibm.com>
	<1249068948.1104.0.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	Oren Laaden <orenl@cs.columbia.edu>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:33423 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751008AbZGaTlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2009 15:41:06 -0400
In-Reply-To: <1249068948.1104.0.camel@Maple> (John Dykstra's message of "Fri\, 31 Jul 2009 19\:35\:48 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +       CKPT_COPY(op, hh->tcp.last_synq_overflow, sk->last_synq_overflow);

JD> This sock field was removed from the mainline kernel by commit
JD> a0f82f64e26929776c58a5c93c2ecb38e3d82815.

Ah, thanks for this.  I'm trying to get the UNIX patch updated with
the latest round of feedback and then I'll take this and the other
comments forward with the INET patch.

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
