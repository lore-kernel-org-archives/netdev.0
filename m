From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2 breakage
Date: Fri, 20 Jul 2007 16:11:00 +0100
Message-ID: <20070720161100.53456f9d@oldman.hamilton.local>
References: <20070720150733.GG21668@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41753 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933882AbXGTPM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 11:12:26 -0400
In-Reply-To: <20070720150733.GG21668@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 20 Jul 2007 16:07:33 +0100
Al Viro <viro@ftp.linux.org.uk> wrote:

> 	Doing |= 1 << 19 to 16bit unsigned is not particulary useful;
> that register is 32bit, unlike the ones dealt with in the rest of
> function, so we need u32 variable here.
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

Yes, thanks.  This only applies to the YUKON_EX hardware support
that is new (post 2.6.22), and no one but me has the boards yet,
so not a big impact.
