From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH 13/30] net: Don't do pointless kmalloc return value casts
 in zd1211 driver
Date: Thu, 30 Aug 2007 19:47:11 -0400
Message-ID: <46D756FF.3090602@gentoo.org>
References: <1554af80879a7ef2f78a4d654f23c248203500d9.1187912217.git.jesper.juhl@gmail.com>	 <d551047daed1cb4d9de1eff956268a468c9837f6.1187912217.git.jesper.juhl@gmail.com>	 <46D70467.1040109@gentoo.org> <9a8748490708301320o49d8e794vc5c37ffc938006f1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ulrich Kunitz <kune@deine-taler.de>,
	linux-wireless@vger.kernel.org
To: Jesper Juhl <jesper.juhl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp131.iad.emailsrvr.com ([207.97.245.131]:46224 "EHLO
	smtp131.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758795AbXH3Xsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2007 19:48:54 -0400
In-Reply-To: <9a8748490708301320o49d8e794vc5c37ffc938006f1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Juhl wrote:
> What would be wrong in applying my patch that removes the cast of the
> kmalloc() return value and then also remove the "__nocast" here?

We use it as a safety measure when coding. For example the write 
register function takes an address and a value. We got one of these the 
wrong way round once, and had a non-obvious bug.

nocast and sparse helps us prevent this.

Daniel

