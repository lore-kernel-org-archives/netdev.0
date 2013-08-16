From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 3/3] [RFC] TCP syncookies: only allow 3 MSS values by
 default to mitigate spoofing attacks
Date: Fri, 16 Aug 2013 23:31:01 +0200
Message-ID: <20130816213101.GD5154@breakpoint.cc>
References: <520A3B4A.1050704@jakoblell.com>
 <20130815235743.GA25665@midget.suse.cz>
 <20130816000523.GC11950@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakob Lell <jakob@jakoblell.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34382 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751771Ab3HPWbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 18:31:46 -0400
Content-Disposition: inline
In-Reply-To: <20130816000523.GC11950@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac <jbohac@suse.cz> wrote:
> Rationale for the new values
> - most packets are (1500 - headers); (1450 - headers) is not a huge waste and
>   prevents fallback to much lower values

Still, 1410 seems weird.

> - clients will rarely send MSS below 536, so that's a safe fallback

Can you elaborate?
You say 'is a safe fallback', yet it is removed in the patch?

> - we need to keep the minimum (64)

Why?
