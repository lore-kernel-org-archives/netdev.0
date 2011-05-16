From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next-2.6] ipv4: more compliant RFC 3168 support
Date: Mon, 16 May 2011 23:33:37 +0200
Message-ID: <20110516213336.GD3290@nuttenaction>
References: <201105141938.28344.v13@v13.gr>
 <1305464176.3120.113.camel@edumazet-laptop>
 <1305466542.3120.129.camel@edumazet-laptop>
 <201105151808.39231.v13@v13.gr>
 <1305475310.3120.146.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefanos Harhalakis <v13@v13.gr>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:56366 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756301Ab1EPVdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 17:33:38 -0400
Content-Disposition: inline
In-Reply-To: <1305475310.3120.146.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2011-05-15 18:01:50 [+0200]:

>Problem of this version is that common frames in the Internet (NOT_ECT
>or ECT_X or ECT_X) will take the longest path to come to "return 0;"
>
>a switch() version is fast because gcc emits a table based jump

Sure? Is the table access not an dCache miss? E.g.

4003dc: ff 24 fd 58 06 40 00  jmpq   *0x400658(,%rdi,8)

Not sure if jump table access is superior these days ...


Hagen
