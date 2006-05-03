From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: Disabling "TCP Treason uncloaked"
Date: Wed, 3 May 2006 13:47:31 +0200
Message-ID: <200605031347.31281.netdev@axxeo.de>
References: <E1FbBPy-0007Iu-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Just Marc <marc@corky.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:9902 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S965151AbWECLrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 07:47:48 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1FbBPy-0007Iu-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> BTW, this message is already under net_ratelimit so I don't see any
> urgency in getting rid of it completely.  If we're going down the
> path of disabling it, we probably should go for something more global
> rather than a sysctl that controls this one message.

Already there: /proc/sys/net/core/{message_cost,message_burst}

Just set burst to 0 and cost to a very big value to basically supppress
all net_ratelimit()ed messages.

Or did you think of sth. else?

Regards

Ingo Oeser
