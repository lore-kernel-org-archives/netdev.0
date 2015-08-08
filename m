From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] netlink: make sure -EBUSY won't escape from
 netlink_insert
Date: Sat, 8 Aug 2015 19:23:43 +0200
Message-ID: <20150808172343.GB15145@pox.localdomain>
References: <d466c48264ca677f0fc61ff76526780c32c37cb5.1438898409.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	torvalds@linux-foundation.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:38184 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992472AbbHHRXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Aug 2015 13:23:46 -0400
Received: by wibxm9 with SMTP id xm9so101328550wib.1
        for <netdev@vger.kernel.org>; Sat, 08 Aug 2015 10:23:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <d466c48264ca677f0fc61ff76526780c32c37cb5.1438898409.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/07/15 at 12:26am, Daniel Borkmann wrote:
> Linus reports the following deadlock on rtnl_mutex; triggered only
> once so far (extract):
> 
[...] 
> Reference: http://thread.gmane.org/gmane.linux.network/372676
> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Thomas Graf <tgraf@suug.ch>
