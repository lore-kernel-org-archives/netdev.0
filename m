From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v6)
Date: Tue, 04 Aug 2009 10:13:09 -0700
Message-ID: <87ocqvlcyi.fsf@caffeine.danplanet.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com>
	<1248295301-30930-6-git-send-email-danms@us.ibm.com>
	<4A6F2D62.9040005@librato.com> <87ljm8czsf.fsf@caffeine.danplanet.com>
	<4A6F6B19.9010508@librato.com> <878wi6yxui.fsf@caffeine.danplanet.com>
	<4A77F0EF.9090602@librato.com> <87ws5jlidl.fsf@caffeine.danplanet.com>
	<4A786A6F.10902@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Oren Laadan <orenl@librato.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:39279 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932953AbZHDRNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 13:13:23 -0400
In-Reply-To: <4A786A6F.10902@librato.com> (Oren Laadan's message of "Tue\, 04 Aug 2009 13\:05\:51 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OL> What I meant is that restore (and therefore checkpoint) need to
OL> know how to handle skb's sent with sendto() but without proper
OL> connection, where the target socket is still unconnected.

I see.  I'll have to think on that a bit.

OL> I'm ok with declaring this case unsupported for now and put it in
OL> the 'todo' list, and meanwhile work towards getting the current
OL> afunix patches into the cr-dev tree. (As long as it doesn't it
OL> will be buried there forever...)

Okay, I think that would be most productive :)

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
