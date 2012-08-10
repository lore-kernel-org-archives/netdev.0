From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH][XFRM] Replace rwlock on xfrm_policy_afinfo with rcu
Date: Fri, 10 Aug 2012 08:26:32 +0200
Message-ID: <1344579992.31104.1224.camel@edumazet-glaptop>
References: <1344316904-2544-1-git-send-email-Priyanka.Jain@freescale.com>
	 <1344407147.28967.212.camel@edumazet-glaptop>
	 <50220AB2.5030504@windriver.com>
	 <AC83832D6324604BB08FAE5A33553F1907A9B368@039-SN2MPN1-012.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Fan Du <fan.du@windriver.com>
To: Jain Priyanka-B32167 <B32167@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:49854 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754355Ab2HJG0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 02:26:38 -0400
Received: by wibhq12 with SMTP id hq12so921495wib.1
        for <netdev@vger.kernel.org>; Thu, 09 Aug 2012 23:26:36 -0700 (PDT)
In-Reply-To: <AC83832D6324604BB08FAE5A33553F1907A9B368@039-SN2MPN1-012.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-10 at 04:28 +0000, Jain Priyanka-B32167 wrote:
> Hello Eric Dumazet,
> 
> Like Fan Du, even I could not see the bug in the current code. Can you please elaborate
> Yes, it might be invalid, but all the callers have checked the return value, thus use it in a sane way.
> So I don't follow "Note the current code is buggy as well".
> 
> Am I missing something here?
> 

Hmm, I misread the code, sorry for the false alarm.
