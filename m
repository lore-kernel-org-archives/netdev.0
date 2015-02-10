From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: Kernel sends ICMP unreachable for GRE packets even if there is a
 listening socket
Date: Tue, 10 Feb 2015 17:16:25 +0100
Message-ID: <20150210161625.GA5440@sesse.net>
References: <20150210152410.GA9225@sesse.net>
 <1423584596.28434.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:49411 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752267AbbBJQQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 11:16:30 -0500
Content-Disposition: inline
In-Reply-To: <1423584596.28434.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2015 at 08:09:56AM -0800, Eric Dumazet wrote:
>> Can this be suppressed when I have such a socket giong? ip6tables -A OUTPUT can
>> stop them, but it seems very hacky and kludgy.
> Thats because you loaded ip6_gre maybe ?

I have loaded ip6_gre, yes. But I might need the kernel variant for other
tunnels, so unloading it is a suboptimal workaround.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
