From: Romain Francoise <romain@orebokech.com>
Subject: Re: [PATCH] tcp: tcp_replace_ts_recent() should not be called from tcp_validate_incoming()
Date: Tue, 13 Nov 2012 13:02:52 +0100
Message-ID: <87k3tp6783.fsf@silenus.orebokech.com>
References: <1352793951.6185.28.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	"H.K. Jerry Chu" <hkchu@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stringer.orebokech.com ([88.190.240.207]:41611 "EHLO
	stringer.orebokech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680Ab2KMMCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 07:02:53 -0500
In-Reply-To: <1352793951.6185.28.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Tue, 13 Nov 2012 00:05:51 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> We added support for RFC 5962 in latest kernels but TCP fails
> to perform exhaustive check of ACK sequence.

You probably meant 5961...
