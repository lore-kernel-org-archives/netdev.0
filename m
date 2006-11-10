From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH] IPv6: optimize echo reply checksum calculation
Date: Fri, 10 Nov 2006 17:34:22 +0000
Message-ID: <20061110173422.GM29920@ftp.linux.org.uk>
References: <20061108221332.GI29920@ftp.linux.org.uk> <45536622.90708@hp.com> <20061109.151402.15590179.davem@davemloft.net> <4554A811.5060402@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:27275 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S1161887AbWKJRe1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 12:34:27 -0500
To: Brian Haley <brian.haley@hp.com>
Content-Disposition: inline
In-Reply-To: <4554A811.5060402@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 10, 2006 at 11:25:53AM -0500, Brian Haley wrote:
> Since the only difference between echo requests and echo replies is the 
> ICMPv6 type value (which is a difference of 1), just subtracting one 
> from the request checksum will result in the correct checksum for the reply.

Um, no.  That will *not* result in correct checksum.  Please, RTFRFC 1071.
