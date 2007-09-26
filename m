From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH - net-2.6.24 0/2] Introduce and use print_ip and
	print_ipv6
Date: Tue, 25 Sep 2007 21:36:38 -0700
Message-ID: <1190781398.17052.18.camel@localhost>
References: <1190271211.26101.91.camel@localhost>
	 <20070925.192917.21908774.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com,
	akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2714 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758963AbXIZEgo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 00:36:44 -0400
In-Reply-To: <20070925.192917.21908774.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-09-25 at 19:29 -0700, David Miller wrote:
> I'm going to hold on this for now, there is no universal
> agreement that this is something we want to do and I'd
> like to take care of getting the more certain stuff into
> net-2.6.24 before "iffy" bits like this one.

Here's an argument for inclusion:

defconfig without patches:

$ size vmlinux
   text    data     bss     dec     hex filename
4738370  518986  622592 5879948  59b88c vmlinux

defconfig with patches:

$ size vmlinux
   text    data     bss     dec     hex filename
4735238  518986  622592 5876816  59ac50 vmlinux

cheers, Joe

