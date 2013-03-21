From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] filter: add minimal BPF JIT image disassembler
Date: Thu, 21 Mar 2013 11:36:02 -0400 (EDT)
Message-ID: <20130321.113602.2089245142968933066.davem@davemloft.net>
References: <1363817507-7499-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43315 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754414Ab3CUPgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 11:36:03 -0400
In-Reply-To: <1363817507-7499-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 20 Mar 2013 23:11:47 +0100

> This is a minimal stand-alone user space helper, that allows for debugging or
> verification of emitted BPF JIT images. This is in particular useful for
> emitted opcode debugging, since minor bugs in the JIT compiler can be fatal.
> The disassembler is architecture generic and uses libopcodes and libbfd.
 ...
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  I have added a 'net' target for current and future misc tools. I decided not
>  to add an extra man-page, since it's just a very small helper, with an option
>  -o, that is accessible through -h, nothing more. Let me know if that's okay
>  for you, thanks.
> 
>  v1 -> v2: change location of file from scripts/ to tools/net/
>  v2 -> v3: add a Makefile and 'net' target under tools

Applied, thanks Daniel.
