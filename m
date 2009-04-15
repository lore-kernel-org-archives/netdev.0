From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: nf_log fix
Date: Wed, 15 Apr 2009 12:20:47 +0200
Message-ID: <49E5B4FF.50606@trash.net>
References: <20090410191736.21efab8c@mako-desktop>	 <49E4744D.5090205@trash.net>	<49E47C2D.1050508@cosmosbay.com>	 <49E47EA5.3060706@trash.net> <20090414211946.4ea0455e@mako-desktop>	 <49E4EE9C.7040509@cosmosbay.com> <1239742000.24204.9.camel@ice-age> <49E4FB0C.1080103@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Leblond <eric@inl.fr>,
	Mariusz Kozlowski <m.kozlowski@tuxland.pl>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55673 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228AbZDOKU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 06:20:58 -0400
In-Reply-To: <49E4FB0C.1080103@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> OK thanks everybody, I submit it more formally then, using ARRAY_SIZE() macro too :)
> 
> [PATCH] netfilter: nf_log fix
> 
> commit ca735b3aaa945626ba65a3e51145bfe4ecd9e222
> 'netfilter: use a linked list of loggers'
> introduced an array of list_head in "struct nf_logger", but
> forgot to initialize it in nf_log_register(). This resulted
> in oops when calling nf_log_unregister() at module unload time.
> 
> Reported-and-tested-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> Acked-by: Eric Leblond <eric@inl.fr>

Applied, thanks everyone.

