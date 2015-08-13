From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next] net: atl1c: add BQL support
Date: Fri, 14 Aug 2015 00:16:48 +0200
Message-ID: <20150813221648.GA25701@electric-eye.fr.zoreil.com>
References: <55CAE130.8040406@gmail.com>
 <20150812224020.GA31826@electric-eye.fr.zoreil.com>
 <55CC2728.6020309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ron Angeles <ronangeles@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37437 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbbHMWRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 18:17:09 -0400
Content-Disposition: inline
In-Reply-To: <55CC2728.6020309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ron Angeles <ronangeles@gmail.com> :
[...]
> I only have one of these NICs and it is running on something critical
> throughout the weekdays. I can try running these when I have time on a
> weekend.

Thanks, it would be perfect: I can't promise it won't crash.

> Is there any particular way you would suggest testing? Would an
> overnight smoke test with netperf suffice?

Anything that changes timing, packet size, and plays with different
contexts (link change, retrieve stats, etc.).

I'll send an updated patchkit tomorrow. The xmit part is a bit different
from what I'm used to.

-- 
Ueimor
