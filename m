From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [Bugme-new] [Bug 34322] New: No ECN marking in IPv6
Date: Fri, 6 May 2011 19:12:49 +0200
Message-ID: <20110506171249.GA29942@uio.no>
References: <bug-34322-10286@https.bugzilla.kernel.org/>
 <20110505144146.4bc1e744.akpm@linux-foundation.org>
 <1304694292.3066.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:53881 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756553Ab1EFRnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 13:43:01 -0400
Content-Disposition: inline
In-Reply-To: <1304694292.3066.29.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 06, 2011 at 05:04:52PM +0200, Eric Dumazet wrote:
> Analysis seems fine, but you also need to change INET_ECN_dontxmit() for
> retransmitted packets.
> 
> Any chance you can refine your patch ?

Sure, but is really checking against NULL the right way of checking for IPv6
sockets? I'd imagined I should have checked address family or something
instead...

/* Steinar */
-- 
Homepage: http://www.sesse.net/
