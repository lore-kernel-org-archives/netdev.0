From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [Bugme-new] [Bug 26632] New: rtl8169 slow to come up and not
 allowing telnetd-ssl negotiation
Date: Thu, 20 Jan 2011 01:12:44 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1101200111450.32026@obet.zrqbmnf.qr>
References: <bug-26632-10286@https.bugzilla.kernel.org/> <20110119145904.d750d49d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, arthur.marsh@internode.on.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:51267 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753509Ab1ATAMp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jan 2011 19:12:45 -0500
In-Reply-To: <20110119145904.d750d49d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 2011-01-19 23:59, Andrew Morton wrote:

>(switched to email.  Please respond via emailed reply-to-all, not via the
>bugzilla web interface).
>
>On Thu, 13 Jan 2011 09:53:26 GMT
>bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=26632
>> 
>>            Summary: rtl8169 slow to come up and not allowing telnetd-ssl
>>                     negotiation
>
>This regression was bisected to
>
>0ab03c2b1478f2438d2c80204f7fef65b1bca9cf is the first bad commit
>    netlink: test for all flags of the NLM_F_DUMP composite

Adressed by dave/net-next-2.6 b8f3ab4290f1e720166e888ea2a1d1d44c4d15dd 
for now while it is being figured out what to really do.

