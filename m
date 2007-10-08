From: David Miller <davem@davemloft.net>
Subject: Re: [Devel] [PATCH][NETNS] Move some code into __init section when
 CONFIG_NET_NS=n
Date: Mon, 08 Oct 2007 00:30:41 -0700 (PDT)
Message-ID: <20071008.003041.55747619.davem@davemloft.net>
References: <4704F083.7090203@openvz.org>
	<20071004140202.GA6180@localhost.sw.ru>
	<20071008.001716.116377615.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: adobriyan@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51895
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750737AbXJHHam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 03:30:42 -0400
In-Reply-To: <20071008.001716.116377615.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Mon, 08 Oct 2007 00:17:16 -0700 (PDT)

> I'm going to apply Pavel's patch, if you want to touch it up do so
> as a followon patch, thanks!

Actually, I take that back, it doesn't even build, I'm therefore
removing the patch:

  LD      .tmp_vmlinux1
`.exit.text' referenced in section `.init.data' of fs/built-in.o: defined in discarded section `.exit.text' of fs/built-in.o
`.exit.text' referenced in section `.init.data' of drivers/built-in.o: defined in discarded section `.exit.text' of drivers/built-in.o
`.exit.text' referenced in section `.init.data' of net/built-in.o: defined in discarded section `.exit.text' of net/built-in.o
`.exit.text' referenced in section `.init.data' of net/built-in.o: defined in discarded section `.exit.text' of net/built-in.o
`.exit.text' referenced in section `.init.data' of net/built-in.o: defined in discarded section `.exit.text' of net/built-in.o
`.exit.text' referenced in section `.init.data' of net/built-in.o: defined in discarded section `.exit.text' of net/built-in.o
`.exit.text' referenced in section `.init.data' of net/built-in.o: defined in discarded section `.exit.text' of net/built-in.o
make: *** [.tmp_vmlinux1] Error 1

Please fix this up and resubmit if you like.
