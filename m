From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Fri, 18 Jul 2008 01:27:54 +0200
Message-ID: <19f34abd0807171627t1dd0ac5bx26535b5e19606835@mail.gmail.com>
References: <20080717214222.GA29449@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Pekka Enberg" <penberg@cs.helsinki.fi>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Ingo Molnar" <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:3681 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104AbYGQX16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 19:27:58 -0400
Received: by yx-out-2324.google.com with SMTP id 8so38982yxm.1
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 16:27:55 -0700 (PDT)
In-Reply-To: <20080717214222.GA29449@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 17, 2008 at 11:42 PM, Ingo Molnar <mingo@elte.hu> wrote:
> With this config:
>
>   http://redhat.com/~mingo/misc/config-Thu_Jul_17_20_24_45_CEST_2008.bad
>

It doesn't actually work. The config says

    # head: 088fcf34

and I checked out this from the tip tree. But kernel-config still
complains about unknown config options... What went wrong?


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
