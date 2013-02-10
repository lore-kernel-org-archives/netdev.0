From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 5/8] wan: Remove unnecessary alloc/OOM messages
Date: Sun, 10 Feb 2013 21:30:27 +0100
Message-ID: <m3zjzb9ajg.fsf@intrepid.localdomain>
References: <cover.1359939012.git.joe@perches.com>
	<392e9b2c652a41f6c5791268dde1eb8c71d0be90.1359939013.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "Jan \"Yenya\" Kasprzak" <kas@fi.muni.cz>,
	Kevin Curtis <kevin.curtis@farsite.co.uk>,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from inx.pm.waw.pl ([195.116.170.130]:36364 "EHLO inx.pm.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755335Ab3BJUaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Feb 2013 15:30:30 -0500
In-Reply-To: <392e9b2c652a41f6c5791268dde1eb8c71d0be90.1359939013.git.joe@perches.com>
	(Joe Perches's message of "Sun, 3 Feb 2013 19:28:12 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> writes:

> alloc failures already get standardized OOM
> messages and a dump_stack.
>
> Hoist assigns from if tests.
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/wan/cosa.c    | 9 ++++-----
>  drivers/net/wan/farsync.c | 6 ++----
>  drivers/net/wan/hdlc.c    | 9 ++++-----
>  drivers/net/wan/x25_asy.c | 1 -
>  4 files changed, 10 insertions(+), 15 deletions(-)

Good to see.

Acked-by: Krzysztof Halasa <khc@pm.waw.pl>
-- 
Krzysztof Halasa
