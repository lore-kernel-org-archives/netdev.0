From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH -resend 4/6] netfilter: Implement RFC 1123 for FTP
 conntrack
Date: Mon, 27 May 2013 14:20:33 +0200
Message-ID: <20130527122033.GA16107@localhost>
References: <1369227552-11743-1-git-send-email-jslaby@suse.cz>
 <1369227552-11743-4-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jirislaby@gmail.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, Jeff Mahoney <jeffm@suse.com>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:42748 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932177Ab3E0MUj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 08:20:39 -0400
Content-Disposition: inline
In-Reply-To: <1369227552-11743-4-git-send-email-jslaby@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 22, 2013 at 02:59:10PM +0200, Jiri Slaby wrote:
> From: Jeff Mahoney <jeffm@suse.com>
> 
>  The FTP conntrack code currently only accepts the following format for
>  the 227 response for PASV:
>  227 Entering Passive Mode (148,100,81,40,31,161).
> 
>  It doesn't accept the following format from an obscure server:
>  227 Data transfer will passively listen to 67,218,99,134,50,144
> 
>  From RFC 1123:
>  The format of the 227 reply to a PASV command is not
>  well standardized.  In particular, an FTP client cannot
>  assume that the parentheses shown on page 40 of RFC-959
>  will be present (and in fact, Figure 3 on page 43 omits
>  them).  Therefore, a User-FTP program that interprets
>  the PASV reply must scan the reply for the first digit
>  of the host and port numbers.

Applied, thanks.
