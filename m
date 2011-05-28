From: Bernd Zeimetz <bzed@debian.org>
Subject: Re: [Bug 35992] Regression: oops when using a bridge interface with
 tg3
Date: Sat, 28 May 2011 13:35:26 +0200
Message-ID: <4DE0DDFE.9080308@debian.org>
References: <bug-35992-17701@https.bugzilla.kernel.org/> <201105281013.p4SADfPS024949@demeter1.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, bzed@debian.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bridge@lists.linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.recluse.de ([217.196.146.213]:60185 "EHLO mail.recluse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751195Ab1E1Lfa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 May 2011 07:35:30 -0400
In-Reply-To: <201105281013.p4SADfPS024949@demeter1.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> OK, this sounds like an already fixed bug.
> 
> (commit : 33eb9873a283a bridge: initialize fake_rtable metrics)
> 
> Could you try latest linux-2.6 tree ?

I've picked the commit into 2.6.39 and it fixed the issue, thanks for the pointer.


Could we please get that included in 2.6.39.1?

Thanks,

Bernd

-- 
 Bernd Zeimetz                            Debian GNU/Linux Developer
 http://bzed.de                                http://www.debian.org
 GPG Fingerprint: ECA1 E3F2 8E11 2432 D485  DD95 EB36 171A 6FF9 435F
