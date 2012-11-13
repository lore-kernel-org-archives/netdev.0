From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: tcp_replace_ts_recent() should not be called from
 tcp_validate_incoming()
Date: Tue, 13 Nov 2012 05:28:52 -0800
Message-ID: <1352813332.6185.29.camel@edumazet-glaptop>
References: <1352793951.6185.28.camel@edumazet-glaptop>
	 <87k3tp6783.fsf@silenus.orebokech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	"H.K. Jerry Chu" <hkchu@google.com>
To: Romain Francoise <romain@orebokech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:33188 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431Ab2KMN2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 08:28:55 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so10643577iea.19
        for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 05:28:54 -0800 (PST)
In-Reply-To: <87k3tp6783.fsf@silenus.orebokech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-13 at 13:02 +0100, Romain Francoise wrote:
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
> > We added support for RFC 5962 in latest kernels but TCP fails
> > to perform exhaustive check of ACK sequence.
> 
> You probably meant 5961...

Oops you're right ;)
