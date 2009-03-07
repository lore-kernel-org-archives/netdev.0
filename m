From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH 1/2] gigaset: return -ENOSYS for unimplemented functions
Date: Sat, 7 Mar 2009 14:26:09 -0800
Message-ID: <20090307142609.2995bb3d@infradead.org>
References: <20090307-patch-00.tilman@imap.cc>
	<20090307-patch-01.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Paul Bolle <pebolle@tiscali.nl>,
	Hansjoerg Lipp <hjlipp@web.de>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48070 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756514AbZCGW1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2009 17:27:25 -0500
In-Reply-To: <20090307-patch-01.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  7 Mar 2009 23:10:57 +0100 (CET)
Tilman Schmidt <tilman@imap.cc> wrote:

> From: Paul Bolle <pebolle@tiscali.nl>
> 
> A number of functions in the usb_gigaset module will return -EINVAL if
> CONFIG_GIGASET_UNDOCREQ is not set. Make these return -ENOSYS as it's
> more specific and it might make it easier to see (from userspace) why
> these functions actually fail.
> 
> Impact: some error return codes changed

ENODEV is what would be more appropriate.

ENOSYS shuoldn't be returned from drivers, only from unimplemented
system calls!


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
