From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Mon, 5 Jan 2009 18:42:19 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901051839330.3057@localhost.localdomain>
References: <20090105.183106.252630446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58363 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751269AbZAFCmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 21:42:55 -0500
In-Reply-To: <20090105.183106.252630446.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 5 Jan 2009, David Miller wrote:
> 
> Jaswinder Singh (1):
>       firmware: convert acenic driver to request_firmware()

Grr. But the old acenic_firmware.h file is left around. Which explains 
this:

>  63 files changed, 11470 insertions(+), 1910 deletions(-)

Ugh. That looks absolutely horrible.

I pulled, but please take a look at your own diffstats and then ask 
yourself if things really look like they should look. Because if you had 
done that, you'd have noticed this.

		Linus
