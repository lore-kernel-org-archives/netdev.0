From: Joe Buehler <aspam@cox.net>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Tue, 26 Oct 2010 10:41:52 -0400
Message-ID: <4CC6E8B0.3070806@cox.net>
References: <loom.20101012T185411-307@post.gmane.org>	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>	 <1287805487.2658.5.camel@edumazet-laptop>	 <1287846669.2658.247.camel@edumazet-laptop>  <4CC30055.5040509@cox.net>	 <1287851745.2658.364.camel@edumazet-laptop>  <4CC6D7CC.5040608@cox.net>	 <1288100208.3169.112.camel@edumazet-laptop>  <4CC6DD69.4020502@cox.net> <1288103614.2622.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eastrmmtao103.cox.net ([68.230.240.9]:35895 "EHLO
	eastrmmtao103.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756841Ab0JZOlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 10:41:53 -0400
In-Reply-To: <1288103614.2622.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> Just to make sure, are you using a single syncw, or a double one ?

I'm using double.  I know about the errata.  It doesn't apply to all
Octeon versions but in their SDK they always use two without worrying
about the chip variant.

What I actually to patch this was look at the current LINUX prerelease
and copy what it does.

We'll see later today if all these changes fix my crash, it takes a
while to encounter it.

Joe Buehler
