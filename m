From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 16216] New: wrong source addr of UDP packets
 when using policy routing
Date: Tue, 22 Jun 2010 08:09:44 +0200
Message-ID: <4C2053A8.4040400@trash.net>
References: <bug-16216-10286@https.bugzilla.kernel.org/>  <20100616093328.0671254b.akpm@linux-foundation.org>  <4C18FFDC.8060102@trash.net> <1276709309.2632.126.camel@edumazet-laptop> <4C190D34.8080100@trash.net> <Pine.LNX.4.64.1006181146100.2662@cube>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Unknown <borg@uu3.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40739 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752676Ab0FVGJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 02:09:45 -0400
In-Reply-To: <Pine.LNX.4.64.1006181146100.2662@cube>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unknown wrote:
> Okey. Did you people came into any conclusions?
> Is there a patch I can test?

As I said, its known and expected behaviour and there's nothing
netfilter can do about it. You could patch your application to use
the SO_MARK socket option to set the socket mark.

